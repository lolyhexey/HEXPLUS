#!/usr/bin/env python3
# encoding: utf-8
import asyncio, socket, sys, getopt

try:
    import uvloop
    asyncio.set_event_loop_policy(uvloop.EventLoopPolicy())
except ImportError:
    pass

PASS = ''
LISTENING_ADDR = '0.0.0.0'
try:
    LISTENING_PORT = int(sys.argv[1])
except:
    LISTENING_PORT = 80
BUFLEN = 4096 * 4
# Optional positional args:
#   argv[2] = DEFAULT_HOST    (host:port to tunnel to when client omits X-Real-Host)
#   argv[3] = STATUS_CODE     (HTTP code in the spoof handshake, e.g. 101, 200, 400, 520)
#   argv[4] = STATUS_MSG      (text after the code; can include HTML payload spoof and \r\n headers)
DEFAULT_HOST = sys.argv[2] if len(sys.argv) > 2 and sys.argv[2] else '127.0.0.1:22'
_status_code = sys.argv[3] if len(sys.argv) > 3 and sys.argv[3] else '101'
_status_msg = sys.argv[4] if len(sys.argv) > 4 and sys.argv[4] else '<font color="null">HEXPLUS</font>'
_status_msg = _status_msg.replace('\\r\\n', '\r\n').replace('\\n', '\n')
RESPONSE = ('HTTP/1.1 ' + _status_code + ' ' + _status_msg + '\r\n\r\n').encode()
ALLOWED_PREFIXES = ('127.0.0.1', '0.0.0.0', 'localhost')


def _tune_socket(writer):
    try:
        sock = writer.get_extra_info('socket')
        if sock is None:
            return
        sock.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
        sock.setsockopt(socket.SOL_SOCKET, socket.SO_KEEPALIVE, 1)
        if hasattr(socket, 'TCP_KEEPIDLE'):
            sock.setsockopt(socket.IPPROTO_TCP, socket.TCP_KEEPIDLE, 30)
        if hasattr(socket, 'TCP_KEEPINTVL'):
            sock.setsockopt(socket.IPPROTO_TCP, socket.TCP_KEEPINTVL, 10)
        if hasattr(socket, 'TCP_KEEPCNT'):
            sock.setsockopt(socket.IPPROTO_TCP, socket.TCP_KEEPCNT, 3)
    except OSError:
        pass


def find_header(head, header):
    aux = head.find(header + ': ')
    if aux == -1:
        return ''
    aux = head.find(':', aux)
    head = head[aux+2:]
    aux = head.find('\r\n')
    if aux == -1:
        return ''
    return head[:aux]


def parse_host(host, default_port=80):
    i = host.find(':')
    if i != -1:
        return host[:i], int(host[i+1:])
    return host, default_port


async def pipe(reader, writer):
    try:
        while True:
            data = await reader.read(BUFLEN)
            if not data:
                break
            writer.write(data)
            await writer.drain()
    except Exception:
        pass


async def handle_client(client_reader, client_writer):
    _tune_socket(client_writer)
    target_writer = None
    try:
        data = await client_reader.read(BUFLEN)
        if not data:
            return
        client_buffer = data.decode('utf-8', errors='replace')

        host_port = find_header(client_buffer, 'X-Real-Host')
        if host_port == '':
            host_port = DEFAULT_HOST

        split = find_header(client_buffer, 'X-Split')
        if split != '':
            await client_reader.read(BUFLEN)

        if host_port != '':
            passwd = find_header(client_buffer, 'X-Pass')

            if len(PASS) != 0 and passwd == PASS:
                pass
            elif len(PASS) != 0 and passwd != PASS:
                client_writer.write(b'HTTP/1.1 400 WrongPass!\r\n\r\n')
                await client_writer.drain()
                return

            if any(host_port.startswith(h) for h in ALLOWED_PREFIXES):
                host, port = parse_host(host_port)
                target_reader, target_writer = await asyncio.open_connection(host, port)
                _tune_socket(target_writer)
                client_writer.write(RESPONSE)
                await client_writer.drain()
                await asyncio.gather(
                    pipe(client_reader, target_writer),
                    pipe(target_reader, client_writer)
                )
            else:
                client_writer.write(b'HTTP/1.1 403 Forbidden!\r\n\r\n')
                await client_writer.drain()
        else:
            client_writer.write(b'HTTP/1.1 400 NoXRealHost!\r\n\r\n')
            await client_writer.drain()

    except Exception:
        pass
    finally:
        try:
            client_writer.close()
            await client_writer.wait_closed()
        except Exception:
            pass
        if target_writer:
            try:
                target_writer.close()
                await target_writer.wait_closed()
            except Exception:
                pass


def print_usage():
    print('Use: proxy.py -p <port>')
    print('       proxy.py -b <ip> -p <porta>')
    print('       proxy.py -b 0.0.0.0 -p 22')


def parse_args(argv):
    global LISTENING_ADDR, LISTENING_PORT
    try:
        opts, args = getopt.getopt(argv, "hb:p:", ["bind=", "port="])
    except getopt.GetoptError:
        print_usage()
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print_usage()
            sys.exit()
        elif opt in ("-b", "--bind"):
            LISTENING_ADDR = arg
        elif opt in ("-p", "--port"):
            LISTENING_PORT = int(arg)


async def main_async():
    server = await asyncio.start_server(handle_client, LISTENING_ADDR, LISTENING_PORT)
    print("\033[0;34m━"*8, "\033[1;32m PROXY WEBSOCKET", "\033[0;34m━"*8, "\n")
    print("\033[1;33mIP:\033[1;32m " + LISTENING_ADDR)
    print("\033[1;33mPORTA:\033[1;32m " + str(LISTENING_PORT) + "\n")
    print("\033[0;34m━"*10, "\033[1;32m HEXPLUS", "\033[0;34m━\033[1;37m"*11, "\n")
    async with server:
        await server.serve_forever()


if __name__ == '__main__':
    parse_args(sys.argv[1:])
    try:
        asyncio.run(main_async())
    except KeyboardInterrupt:
        print('Parando...')
