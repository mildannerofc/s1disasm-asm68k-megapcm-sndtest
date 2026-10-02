#!/usr/bin/env python3
"""Minimal Sega Nemesis compressor for 4bpp tile data.

The encoder uses the Shannon-Fano path used by Sega's compressor (the
'accurate' path), including the 0x3F inline prefix and optional XOR mode.
Input size must be a multiple of 0x20 bytes.

The format/algorithm follows the public clownnemesis implementation:
https://github.com/Clownacy/clownnemesis
"""
import argparse
from pathlib import Path

RUNS = 16 * 8

def transformed_nibbles(data, xor):
    history = [0, 0, 0, 0]
    pos = 0
    out = []
    for byte in data:
        value = byte ^ (history[pos] if xor else 0)
        history[pos] = byte
        pos = (pos + 1) & 3
        out.extend((value >> 4, value & 15))
    return out

def find_runs(nibbles):
    occurrences = [[0] * 8 for _ in range(16)]
    sequence = []
    previous = nibbles[0]
    length = 1
    for value in nibbles[1:]:
        if value == previous and length < 8:
            length += 1
        else:
            sequence.append((previous, length))
            occurrences[previous][length - 1] += 1
            previous = value
            length = 1
    sequence.append((previous, length))
    occurrences[previous][length - 1] += 1
    return occurrences, sequence

def make_runs(occurrences):
    # C implementation's NybbleRunFromIndex maps index N to [N % 16][N / 16].
    runs = [
        {"n": n, "l": length, "occ": occurrences[n][length], "code": 0, "bits": 0}
        for n in range(16) for length in range(8)
    ]
    order = list(range(RUNS))
    def get(index):
        return runs[(index & 15) * 8 + (index >> 4)]
    # Stable descending occurrence sort.
    order.sort(key=lambda i: get(i)["occ"], reverse=True)
    total = 0
    for index in order:
        if get(index)["occ"] < 3:
            break
        total += get(index)["occ"]

    state_code = 0
    state_bits = 0

    def split(start, total_occurrences):
        nonlocal state_code, state_bits
        first = get(order[start])
        if first["occ"] == total_occurrences:
            first["code"] = state_code
            first["bits"] = state_bits
            if state_code == (1 << state_bits) - 1:
                first["code"] <<= 1
                first["bits"] += 1
            return
        if state_bits == 8:
            return

        accumulated = 0
        halfway = total_occurrences // 2
        for index in range(start, RUNS):
            run = get(order[index])
            next_accumulated = accumulated + run["occ"]
            if next_accumulated > halfway:
                delta1 = halfway - accumulated
                delta2 = next_accumulated - halfway
                split_occurrences = accumulated if delta1 < delta2 else next_accumulated
                split_index = index if delta1 < delta2 else index + 1
                skip_reserved = state_bits == 5 and state_code == 0x1F
                added_bits = 2 if skip_reserved else 1
                state_code <<= added_bits
                state_bits += added_bits
                split(start, split_occurrences)
                state_code |= 1
                split(split_index, total_occurrences - split_occurrences)
                state_code >>= added_bits
                state_bits -= added_bits
                return
            accumulated = next_accumulated

    split(0, total)

    # Sega's compressor uses a selection sort here, moving only the code fields.
    for i in range(RUNS - 1):
        def size(index):
            value = get(order[index])["bits"]
            return value if value else 0xFFFFFFFF
        smallest = i
        smallest_size = size(i)
        for j in range(i + 1, RUNS):
            current = size(j)
            if current < smallest_size:
                smallest = j
                smallest_size = current
        if smallest != i:
            left = get(order[i])
            right = get(order[smallest])
            left["code"], right["code"] = right["code"], left["code"]
            left["bits"], right["bits"] = right["bits"], left["bits"]
    return runs

def encode_mode(data, xor):
    nibbles = transformed_nibbles(data, xor)
    occurrences, sequence = find_runs(nibbles)
    runs = make_runs(occurrences)
    bits = 0
    first_nybble = [True] * 16
    for run in runs:
        if run["bits"]:
            bits += (24 if first_nybble[run["n"]] else 16)
            first_nybble[run["n"]] = False
            bits += run["bits"] * run["occ"]
        else:
            bits += 13 * run["occ"]
    return bits, runs, sequence

def compress(data):
    if not data or len(data) % 0x20:
        raise ValueError("input size must be a non-zero multiple of 0x20")
    regular = encode_mode(data, False)
    xored = encode_mode(data, True)
    if regular[0] <= xored[0]:
        _, runs, sequence = regular
        xor = False
    else:
        _, runs, sequence = xored
        xor = True

    tiles = len(data) // 0x20
    output = bytearray((((tiles >> 8) & 0x7F) | (0x80 if xor else 0), tiles & 0xFF))
    previous_nybble = 0xFF
    for n in range(16):
        for length in range(8):
            run = runs[n * 8 + length]
            if not run["bits"]:
                continue
            if n != previous_nybble:
                previous_nybble = n
                output.append(0x80 | n)
            output.append((length << 4) | run["bits"])
            output.append(run["code"] & 0xFF)
    output.append(0xFF)

    bit_buffer = 0
    bits_done = 0
    def write_bit(bit):
        nonlocal bit_buffer, bits_done
        bit_buffer = ((bit_buffer << 1) | bit) & 0xFF
        bits_done += 1
        if bits_done == 8:
            output.append(bit_buffer)
            bit_buffer = bits_done = 0
    def write_bits(value, count):
        for shift in range(count - 1, -1, -1):
            write_bit((value >> shift) & 1)

    for n, run_length in sequence:
        run = runs[n * 8 + run_length - 1]
        if run["bits"]:
            write_bits(run["code"], run["bits"])
        else:
            write_bits(0x3F, 6)
            write_bits(run_length - 1, 3)
            write_bits(n, 4)
    # Accurate/Sega-compatible mode emits a final byte even when aligned.
    if bits_done or True:
        output.append((bit_buffer << (8 - bits_done)) & 0xFF)
    return bytes(output)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("input", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    compressed = compress(args.input.read_bytes())
    args.output.write_bytes(compressed)
    print(f"Nemesis: {len(args.input.read_bytes())} -> {len(compressed)} bytes")

if __name__ == "__main__":
    main()
