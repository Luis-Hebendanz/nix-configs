#!/usr/bin/env python3

import os 
import argparse
import re
import subprocess
import sys


def ldd(filename):
    libs = [] 

    p = subprocess.Popen(["ldd", filename], 
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        )

    result = p.stdout.readlines()

    for x in result:
        s = x.split()
        if b"statically" == s[0]:
            continue
        libs.append(os.path.basename(s[0]).decode())

    return libs 

parser = argparse.ArgumentParser(description='Generate .so dep tree')
parser.add_argument("--dest", default=".")

args = parser.parse_args()


r = re.compile(".*\.so\.*")

deps = {}


# Set the directory you want to start from
rootDir = args.dest
print(f"Walking directory: {rootDir}")

for basepath, dirnames, filenames in os.walk(rootDir):
    for fname in filenames:
        if r.match(fname):
            path = os.path.join(basepath, fname)
            libs = ldd(path)
            for lib in libs:
                if deps.get(lib) is None:
                    deps[lib] = []
                deps[lib].append(os.path.basename(path))

def sort_func(data):
    data = data[1]
    if "more then ten" in data:
        return 100
    return len(data)

deps = dict(sorted(deps.items(), key=sort_func, reverse=False))

for (key, val) in deps.items():
    msg = "{:<30} => {}"
    if len(val) > 10:
        print(msg.format(key, "more then ten"))
    else:
        print(msg.format(key, val))           
