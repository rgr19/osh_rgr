import subprocess as sp
import socket
import psutil


def interfaces_up():
    cmd = 'ip link show | grep UP | grep -v DOWN | grep -v LOOPBACK'
    proc = sp.Popen(cmd, stdout=sp.PIPE, stderr=sp.PIPE, shell=True)
    stdout = str(proc.communicate()[0]).replace(':', '')
    return [line.split()[1] for line in stdout.splitlines()]


def interfaces_addrs(intfs):
    net_if = psutil.net_if_addrs()
    out = {}
    for intf in intfs:
        inets = filter(lambda x: x.family == socket.AF_INET, net_if[intf])
        out[intf] = list(map(lambda x: x.address, inets))
    return out

def get_interfaces_up():
    o = interfaces_addrs(interfaces_up())
    o = ['{}:[{}]'.format(k, ' '.join(o[k])) for k in o]
    return '<'+' '.join(o)+'>'


if __name__ == '__main__':
    print(get_interfaces_up())
