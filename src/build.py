from struct import pack
with open("bin/ml", "rb") as ml, open("bin/mlhooks", "rb") as hooks, open("bin/modloader.bin", "wb") as mod:
    mod.write(hooks.read())
    data = ml.read()
    mod.write(pack("2I", 0x08800500, len(data)))
    mod.write(data)
    mod.write(pack("2i", -1, 0))
