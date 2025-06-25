from struct import pack

with open("bin/ml", "rb") as ml, open("bin/modloader.bin", "wb") as mod:
    data = ml.read()
    mod.write(pack("2I", 0x08800480, len(data)))
    mod.write(data)
    mod.write(pack("2i", -1, 0))
