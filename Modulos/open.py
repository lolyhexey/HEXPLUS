#!/usr/bin/env python3
# encoding: utf-8
import asyncio, sys
from os import system
system("clear")

IP = '0.0.0.0'
try:
    PORT = int(sys.argv[1])
except:
    PORT = 8080
PASS = ''
BUFLEN = 8196 * 8
TIMEOUT = 60
DEFAULT_HOST = '0.0.0.0:1194'
RESPONSE = b"HTTP/1.1 200 Connection established\r\nContent-length: 0\r\n\r\n"

log_lock = asyncio.Lock()


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


def parse_host(host, default_port=22):
    i = host.find(':')
    if i != -1:
        return host[:i], int(host[i+1:])
    return host, default_port


async def print_log(msg):
    async with log_lock:
        print(msg)


async def pipe(reader, writer):
    try:
        while True:
            data = await asyncio.wait_for(reader.read(BUFLEN), timeout=TIMEOUT)
            if not data:
                break
            writer.write(data)
            await writer.drain()
    except Exception:
        pass


async def handle_client(client_reader, client_writer):
    addr = client_writer.get_extra_info('peername')
    log = 'Conexao: ' + str(addr)
    target_writer = None
    try:
        data = await asyncio.wait_for(client_reader.read(BUFLEN), timeout=TIMEOUT)
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

            if host_port.startswith(IP):
                log += ' - CONNECT ' + host_port
                host, port = parse_host(host_port)
                target_reader, target_writer = await asyncio.open_connection(host, port)
                client_writer.write(RESPONSE)
                await client_writer.drain()
                await print_log(log)
                await asyncio.gather(
                    pipe(client_reader, target_writer),
                    pipe(target_reader, client_writer)
                )
            else:
                client_writer.write(b'HTTP/1.1 403 Forbidden!\r\n\r\n')
                await client_writer.drain()
        else:
            print('- No X-Real-Host!')
            client_writer.write(b'HTTP/1.1 400 NoXRealHost!\r\n\r\n')
            await client_writer.drain()

    except Exception as e:
        log += ' - error: ' + str(e)
        await print_log(log)
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


async def main_async():
    server = await asyncio.start_server(handle_client, IP, PORT)
    print("\033[0;34m━"*8, "\033[1;32m PROXY SOCKS", "\033[0;34m━"*8, "\n")
    print("\033[1;33mIP:\033[1;32m " + IP)
    print("\033[1;33mPORTA:\033[1;32m " + str(PORT) + "\n")
    print("\033[0;34m━"*10, "\033[1;32m HEXPLUS", "\033[0;34m━\033[1;37m"*11, "\n")
    async with server:
        await server.serve_forever()


if __name__ == '__main__':
    try:
        asyncio.run(main_async())
    except KeyboardInterrupt:
        print('\nParando...')
