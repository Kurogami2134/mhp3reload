from struct import pack, unpack
from ModIO import CwCheatIO

with open("bin/preload.bin", "rb") as mod, CwCheatIO("bin/CHEAT.TXT") as cheat:
    index = 0
    while (addr := unpack("i", mod.read(4))[0]) != -1:
        index += 1
        size = unpack("i", mod.read(4))[0]
        cheat.seek(addr)
        cheat.write(f"mhp3reload {index}/?")
        cheat.write_once(mod.read(size))
