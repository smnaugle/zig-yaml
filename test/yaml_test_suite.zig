const std = @import("std");
const Yaml = @import("yaml").Yaml;
const Io = std.Io;
const fs = std.fs;

const alloc = std.testing.allocator;
const io = std.testing.io;

const suite_prefix = "test/yaml-test-suite/";

fn loadFromFile(file_path: []const u8) !Yaml {
    const source = try std.Io.Dir.cwd().readFileAlloc(io, file_path, alloc, .unlimited);
    defer alloc.free(source);

    var yaml: Yaml = .{ .source = source };
    errdefer yaml.deinit(alloc);
    try yaml.load(alloc);
    return yaml;
}

fn assertOutEqual(yaml: *const Yaml, file_path: []const u8) !void {
    const out_yaml = try std.Io.Dir.cwd().readFileAlloc(io, file_path, alloc, .unlimited);
    defer alloc.free(out_yaml);

    var allocating = Io.Writer.Allocating.init(alloc);
    defer allocating.deinit();

    try yaml.stringify(&allocating.writer);

    try std.testing.expectEqualStrings(out_yaml, allocating.written());
}

fn assertFail(file_path: []const u8) !void {
    try std.testing.expect(if (loadFromFile(file_path)) |_| false else |_| true);
}

fn runTest(dir_path: []const u8) !void {
    const full_path = try fs.path.join(alloc, &.{ suite_prefix, dir_path });
    defer alloc.free(full_path);

    const error_path = try fs.path.join(alloc, &.{ full_path, "error" });
    defer alloc.free(error_path);

    const in_path = try fs.path.join(alloc, &.{ full_path, "in.yaml" });
    defer alloc.free(in_path);

    const out_path = try fs.path.join(alloc, &.{ full_path, "out.yaml" });
    defer alloc.free(out_path);

    const cwd = Io.Dir.cwd();

    // Assert error
    blk: {
        cwd.access(io, error_path, .{}) catch break :blk;
        return try assertFail(in_path);
    }

    var yaml = try loadFromFile(in_path);
    defer yaml.deinit(alloc);

    blk: {
        cwd.access(io, out_path, .{}) catch break :blk;
        return try assertOutEqual(&yaml, out_path);
    }
}

// test "229Q - Spec Example 2.4. Sequence of Mappings" {
//     try runTest("229Q");
// }

test "236B - Invalid value after mapping" {
    try runTest("236B");
}

// test "26DV - Whitespace around colon in mappings" {
//     try runTest("26DV");
// }

// test "27NA - Spec Example 5.9. Directive Indicator" {
//     try runTest("27NA");
// }

// test "2AUY - Tags in Block Sequence" {
//     try runTest("2AUY");
// }

test "2CMS - Invalid mapping in plain multiline" {
    try runTest("2CMS");
}

// test "2EBW - Allowed characters in keys" {
//     try runTest("2EBW");
// }

// test "2G84/00 - Literal modifers" {
//     try runTest("2G84/00");
// }

// test "2G84/01 - Literal modifers" {
//     try runTest("2G84/01");
// }

test "2G84/02 - Literal modifers" {
    try runTest("2G84/02");
}

test "2G84/03 - Literal modifers" {
    try runTest("2G84/03");
}

// test "2JQS - Block Mapping with Missing Keys" {
//     try runTest("2JQS");
// }

// test "2LFX - Spec Example 6.13. Reserved Directives [1.3]" {
//     try runTest("2LFX");
// }

// test "2SXE - Anchors With Colon in Name" {
//     try runTest("2SXE");
// }

// test "2XXW - Spec Example 2.25. Unordered Sets" {
//     try runTest("2XXW");
// }

// test "33X3 - Three explicit integers in a block sequence" {
//     try runTest("33X3");
// }

// test "35KP - Tags for Root Objects" {
//     try runTest("35KP");
// }

// test "36F6 - Multiline plain scalar with empty line" {
//     try runTest("36F6");
// }

test "3ALJ - Block Sequence in Block Sequence" {
    try runTest("3ALJ");
}

// test "3GZX - Spec Example 7.1. Alias Nodes" {
//     try runTest("3GZX");
// }

// test "3HFZ - Invalid content after document end marker" {
//     try runTest("3HFZ");
// }

// test "3MYT - Plain Scalar looking like key, comment, anchor and tag" {
//     try runTest("3MYT");
// }

// test "3R3P - Single block sequence with anchor" {
//     try runTest("3R3P");
// }

test "3RLN/00 - Leading tabs in double quoted" {
    try runTest("3RLN/00");
}

// test "3RLN/01 - Leading tabs in double quoted" {
//     try runTest("3RLN/01");
// }

test "3RLN/02 - Leading tabs in double quoted" {
    try runTest("3RLN/02");
}

test "3RLN/03 - Leading tabs in double quoted" {
    try runTest("3RLN/03");
}

// test "3RLN/04 - Leading tabs in double quoted" {
//     try runTest("3RLN/04");
// }

test "3RLN/05 - Leading tabs in double quoted" {
    try runTest("3RLN/05");
}

// test "3UYS - Escaped slash in double quotes" {
//     try runTest("3UYS");
// }

// test "4ABK - Flow Mapping Separate Values" {
//     try runTest("4ABK");
// }

// test "4CQQ - Spec Example 2.18. Multi-line Flow Scalars" {
//     try runTest("4CQQ");
// }

// test "4EJS - Invalid tabs as indendation in a mapping" {
//     try runTest("4EJS");
// }

// test "4FJ6 - Nested implicit complex keys" {
//     try runTest("4FJ6");
// }

test "4GC6 - Spec Example 7.7. Single Quoted Characters" {
    try runTest("4GC6");
}

test "4H7K - Flow sequence with invalid extra closing bracket" {
    try runTest("4H7K");
}

test "4HVU - Wrong indendation in Sequence" {
    try runTest("4HVU");
}

test "4JVG - Scalar value with two anchors" {
    try runTest("4JVG");
}

// test "4MUZ/00 - Flow mapping colon on line after key" {
//     try runTest("4MUZ/00");
// }

// test "4MUZ/01 - Flow mapping colon on line after key" {
//     try runTest("4MUZ/01");
// }

// test "4MUZ/02 - Flow mapping colon on line after key" {
//     try runTest("4MUZ/02");
// }

// test "4Q9F - Folded Block Scalar [1.3]" {
//     try runTest("4Q9F");
// }

// test "4QFQ - Spec Example 8.2. Block Indentation Indicator [1.3]" {
//     try runTest("4QFQ");
// }

// test "4RWC - Trailing spaces after flow collection" {
//     try runTest("4RWC");
// }

test "4UYU - Colon in Double Quoted String" {
    try runTest("4UYU");
}

// test "4V8U - Plain scalar with backslashes" {
//     try runTest("4V8U");
// }

// test "4WA9 - Literal scalars" {
//     try runTest("4WA9");
// }

// test "4ZYM - Spec Example 6.4. Line Prefixes" {
//     try runTest("4ZYM");
// }

// test "52DL - Explicit Non-Specific Tag [1.3]" {
//     try runTest("52DL");
// }

// test "54T7 - Flow Mapping" {
//     try runTest("54T7");
// }

test "55WF - Invalid escape in double quoted string" {
    try runTest("55WF");
}

// test "565N - Construct Binary" {
//     try runTest("565N");
// }

// test "57H4 - Spec Example 8.22. Block Collection Nodes" {
//     try runTest("57H4");
// }

// test "58MP - Flow mapping edge cases" {
//     try runTest("58MP");
// }

// test "5BVJ - Spec Example 5.7. Block Scalar Indicators" {
//     try runTest("5BVJ");
// }

// test "5C5M - Spec Example 7.15. Flow Mappings" {
//     try runTest("5C5M");
// }

// test "5GBF - Spec Example 6.5. Empty Lines" {
//     try runTest("5GBF");
// }

// test "5KJE - Spec Example 7.13. Flow Sequence" {
//     try runTest("5KJE");
// }

test "5LLU - Block scalar with wrong indented line after spaces only" {
    try runTest("5LLU");
}

// test "5MUD - Colon and adjacent value on next line" {
//     try runTest("5MUD");
// }

// test "5NYZ - Spec Example 6.9. Separated Comment" {
//     try runTest("5NYZ");
// }

// test "5T43 - Colon at the beginning of adjacent flow scalar" {
//     try runTest("5T43");
// }

// test "5TRB - Invalid document-start marker in doublequoted tring" {
//     try runTest("5TRB");
// }

// test "5TYM - Spec Example 6.21. Local Tag Prefix" {
//     try runTest("5TYM");
// }

// test "5U3A - Sequence on same Line as Mapping Key" {
//     try runTest("5U3A");
// }

// test "5WE3 - Spec Example 8.17. Explicit Block Mapping Entries" {
//     try runTest("5WE3");
// }

test "62EZ - Invalid block mapping key on same line as previous key" {
    try runTest("62EZ");
}

// test "652Z - Question mark at start of flow key" {
//     try runTest("652Z");
// }

test "65WH - Single Entry Block Sequence" {
    try runTest("65WH");
}

// test "6BCT - Spec Example 6.3. Separation Spaces" {
//     try runTest("6BCT");
// }

// test "6BFJ - Mapping, key and flow sequence item anchors" {
//     try runTest("6BFJ");
// }

// test "6CA3 - Tab indented top flow" {
//     try runTest("6CA3");
// }

// test "6CK3 - Spec Example 6.26. Tag Shorthands" {
//     try runTest("6CK3");
// }

// test "6FWR - Block Scalar Keep" {
//     try runTest("6FWR");
// }

// test "6H3V - Backslashes in singlequotes" {
//     try runTest("6H3V");
// }

// test "6HB6 - Spec Example 6.1. Indentation Spaces" {
//     try runTest("6HB6");
// }

// test "6JQW - Spec Example 2.13. In literals, newlines are preserved" {
//     try runTest("6JQW");
// }

test "6JTT - Flow sequence without closing bracket" {
    try runTest("6JTT");
}

// test "6JWB - Tags for Block Objects" {
//     try runTest("6JWB");
// }

// test "6KGN - Anchor for empty node" {
//     try runTest("6KGN");
// }

// test "6LVF - Spec Example 6.13. Reserved Directives" {
//     try runTest("6LVF");
// }

// test "6M2F - Aliases in Explicit Block Mapping" {
//     try runTest("6M2F");
// }

// test "6PBE - Zero-indented sequences in explicit mapping keys" {
//     try runTest("6PBE");
// }

test "6S55 - Invalid scalar at the end of sequence" {
    try runTest("6S55");
}

// test "6SLA - Allowed characters in quoted mapping key" {
//     try runTest("6SLA");
// }

// test "6VJK - Spec Example 2.15. Folded newlines are preserved for \"more indented\" and blank lines" {
//     try runTest("6VJK");
// }

// test "6WLZ - Spec Example 6.18. Primary Tag Handle [1.3]" {
//     try runTest("6WLZ");
// }

// test "6WPF - Spec Example 6.8. Flow Folding [1.3]" {
//     try runTest("6WPF");
// }

// test "6XDY - Two document start markers" {
//     try runTest("6XDY");
// }

// test "6ZKB - Spec Example 9.6. Stream" {
//     try runTest("6ZKB");
// }

// test "735Y - Spec Example 8.20. Block Node Types" {
//     try runTest("735Y");
// }

// test "74H7 - Tags in Implicit Mapping" {
//     try runTest("74H7");
// }

// test "753E - Block Scalar Strip [1.3]" {
//     try runTest("753E");
// }

// test "7A4E - Spec Example 7.6. Double Quoted Lines" {
//     try runTest("7A4E");
// }

// test "7BMT - Node and Mapping Key Anchors [1.3]" {
//     try runTest("7BMT");
// }

// test "7BUB - Spec Example 2.10. Node for “Sammy Sosa” appears twice in this document" {
//     try runTest("7BUB");
// }

// test "7FWL - Spec Example 6.24. Verbatim Tags" {
//     try runTest("7FWL");
// }

test "7LBH - Multiline double quoted implicit keys" {
    try runTest("7LBH");
}

test "7MNF - Missing colon" {
    try runTest("7MNF");
}

// test "7T8X - Spec Example 8.10. Folded Lines - 8.13. Final Empty Lines" {
//     try runTest("7T8X");
// }

// test "7TMG - Comment in flow sequence before comma" {
//     try runTest("7TMG");
// }

// test "7W2P - Block Mapping with Missing Values" {
//     try runTest("7W2P");
// }

// test "7Z25 - Bare document after document end marker" {
//     try runTest("7Z25");
// }

// test "7ZZ5 - Empty flow collections" {
//     try runTest("7ZZ5");
// }

// test "82AN - Three dashes and content without space" {
//     try runTest("82AN");
// }

// test "87E4 - Spec Example 7.8. Single Quoted Implicit Keys" {
//     try runTest("87E4");
// }

// test "8CWC - Plain mapping key ending with colon" {
//     try runTest("8CWC");
// }

// test "8G76 - Spec Example 6.10. Comment Lines" {
//     try runTest("8G76");
// }

// test "8KB6 - Multiline plain flow mapping key without value" {
//     try runTest("8KB6");
// }

// test "8MK2 - Explicit Non-Specific Tag" {
//     try runTest("8MK2");
// }

// test "8QBE - Block Sequence in Block Mapping" {
//     try runTest("8QBE");
// }

// test "8UDB - Spec Example 7.14. Flow Sequence Entries" {
//     try runTest("8UDB");
// }

test "8XDJ - Comment in plain multiline value" {
    try runTest("8XDJ");
}

// test "8XYN - Anchor with unicode character" {
//     try runTest("8XYN");
// }

// test "93JH - Block Mappings in Block Sequence" {
//     try runTest("93JH");
// }

// test "93WF - Spec Example 6.6. Line Folding [1.3]" {
//     try runTest("93WF");
// }

// test "96L6 - Spec Example 2.14. In the folded scalars, newlines become spaces" {
//     try runTest("96L6");
// }

// test "96NN/00 - Leading tab content in literals" {
//     try runTest("96NN/00");
// }

// test "96NN/01 - Leading tab content in literals" {
//     try runTest("96NN/01");
// }

// test "98YD - Spec Example 5.5. Comment Indicator" {
//     try runTest("98YD");
// }

// test "9BXH - Multiline doublequoted flow mapping key without value" {
//     try runTest("9BXH");
// }

// test "9C9N - Wrong indented flow sequence" {
//     try runTest("9C9N");
// }

test "9CWY - Invalid scalar at the end of mapping" {
    try runTest("9CWY");
}

// test "9DXL - Spec Example 9.6. Stream [1.3]" {
//     try runTest("9DXL");
// }

test "9FMG - Multi-level Mapping Indent" {
    try runTest("9FMG");
}

test "9HCY - Need document footer before directives" {
    try runTest("9HCY");
}

test "9J7A - Simple Mapping Indent" {
    try runTest("9J7A");
}

test "9JBA - Invalid comment after end of flow sequence" {
    try runTest("9JBA");
}

// test "9KAX - Various combinations of tags and anchors" {
//     try runTest("9KAX");
// }

// test "9KBC - Mapping starting at --- line" {
//     try runTest("9KBC");
// }

// test "9MAG - Flow sequence with invalid comma at the beginning" {
//     try runTest("9MAG");
// }

// test "9MMA - Directive by itself with no document" {
//     try runTest("9MMA");
// }

// test "9MMW - Single Pair Implicit Entries" {
//     try runTest("9MMW");
// }

// test "9MQT/00 - Scalar doc with '...' in content" {
//     try runTest("9MQT/00");
// }

// test "9MQT/01 - Scalar doc with '...' in content" {
//     try runTest("9MQT/01");
// }

// test "9SA2 - Multiline double quoted flow mapping key" {
//     try runTest("9SA2");
// }

test "9SHH - Spec Example 5.8. Quoted Scalar Indicators" {
    try runTest("9SHH");
}

// test "9TFX - Spec Example 7.6. Double Quoted Lines [1.3]" {
//     try runTest("9TFX");
// }

// test "9U5K - Spec Example 2.12. Compact Nested Mapping" {
//     try runTest("9U5K");
// }

// test "9WXW - Spec Example 6.18. Primary Tag Handle" {
//     try runTest("9WXW");
// }

// test "9YRD - Multiline Scalar at Top Level" {
//     try runTest("9YRD");
// }

// test "A2M4 - Spec Example 6.2. Indentation Indicators" {
//     try runTest("A2M4");
// }

// test "A6F9 - Spec Example 8.4. Chomping Final Line Break" {
//     try runTest("A6F9");
// }

// test "A984 - Multiline Scalar in Mapping" {
//     try runTest("A984");
// }

// test "AB8U - Sequence entry that looks like two with wrong indentation" {
//     try runTest("AB8U");
// }

test "AVM7 - Empty Stream" {
    try runTest("AVM7");
}

test "AZ63 - Sequence With Same Indentation as Parent Mapping" {
    try runTest("AZ63");
}

// test "AZW3 - Lookahead test cases" {
//     try runTest("AZW3");
// }

// test "B3HG - Spec Example 8.9. Folded Scalar [1.3]" {
//     try runTest("B3HG");
// }

test "B63P - Directive without document" {
    try runTest("B63P");
}

test "BD7L - Invalid mapping after sequence" {
    try runTest("BD7L");
}

// test "BEC7 - Spec Example 6.14. “YAML” directive" {
//     try runTest("BEC7");
// }

test "BF9H - Trailing comment in multiline plain scalar" {
    try runTest("BF9H");
}

// test "BS4K - Comment between plain scalar lines" {
//     try runTest("BS4K");
// }

// test "BU8L - Node Anchor and Tag on Seperate Lines" {
//     try runTest("BU8L");
// }

// test "C2DT - Spec Example 7.18. Flow Mapping Adjacent Values" {
//     try runTest("C2DT");
// }

test "C2SP - Flow Mapping Key on two lines" {
    try runTest("C2SP");
}

// test "C4HZ - Spec Example 2.24. Global Tags" {
//     try runTest("C4HZ");
// }

// test "CC74 - Spec Example 6.20. Tag Handles" {
//     try runTest("CC74");
// }

// test "CFD4 - Empty implicit key in single pair flow sequences" {
//     try runTest("CFD4");
// }

// test "CML9 - Missing comma in flow" {
//     try runTest("CML9");
// }

// test "CN3R - Various location of anchors in flow sequence" {
//     try runTest("CN3R");
// }

// test "CPZ3 - Doublequoted scalar starting with a tab" {
//     try runTest("CPZ3");
// }

test "CQ3W - Double quoted string without closing quote" {
    try runTest("CQ3W");
}

// test "CT4Q - Spec Example 7.20. Single Pair Explicit Entry" {
//     try runTest("CT4Q");
// }

test "CTN5 - Flow sequence with invalid extra comma" {
    try runTest("CTN5");
}

// test "CUP7 - Spec Example 5.6. Node Property Indicators" {
//     try runTest("CUP7");
// }

test "CVW2 - Invalid comment after comma" {
    try runTest("CVW2");
}

test "CXX2 - Mapping with anchor on document start line" {
    try runTest("CXX2");
}

test "D49Q - Multiline single quoted implicit keys" {
    try runTest("D49Q");
}

// test "D83L - Block scalar indicator order" {
//     try runTest("D83L");
// }

// test "D88J - Flow Sequence in Block Mapping" {
//     try runTest("D88J");
// }

test "D9TU - Single Pair Block Mapping" {
    try runTest("D9TU");
}

// test "DBG4 - Spec Example 7.10. Plain Characters" {
//     try runTest("DBG4");
// }

// test "DC7X - Various trailing tabs" {
//     try runTest("DC7X");
// }

// test "DE56/00 - Trailing tabs in double quoted" {
//     try runTest("DE56/00");
// }

// test "DE56/01 - Trailing tabs in double quoted" {
//     try runTest("DE56/01");
// }

// test "DE56/02 - Trailing tabs in double quoted" {
//     try runTest("DE56/02");
// }

// test "DE56/03 - Trailing tabs in double quoted" {
//     try runTest("DE56/03");
// }

// test "DE56/04 - Trailing tabs in double quoted" {
//     try runTest("DE56/04");
// }

// test "DE56/05 - Trailing tabs in double quoted" {
//     try runTest("DE56/05");
// }

// test "DFF7 - Spec Example 7.16. Flow Mapping Entries" {
//     try runTest("DFF7");
// }

// test "DHP8 - Flow Sequence" {
//     try runTest("DHP8");
// }

// test "DK3J - Zero indented block scalar with line that looks like a comment" {
//     try runTest("DK3J");
// }

test "DK4H - Implicit key followed by newline" {
    try runTest("DK4H");
}

// test "DK95/00 - Tabs that look like indentation" {
//     try runTest("DK95/00");
// }

// test "DK95/01 - Tabs that look like indentation" {
//     try runTest("DK95/01");
// }

test "DK95/02 - Tabs that look like indentation" {
    try runTest("DK95/02");
}

// test "DK95/03 - Tabs that look like indentation" {
//     try runTest("DK95/03");
// }

// test "DK95/04 - Tabs that look like indentation" {
//     try runTest("DK95/04");
// }

// test "DK95/05 - Tabs that look like indentation" {
//     try runTest("DK95/05");
// }

test "DK95/06 - Tabs that look like indentation" {
    try runTest("DK95/06");
}

// test "DK95/07 - Tabs that look like indentation" {
//     try runTest("DK95/07");
// }

test "DK95/08 - Tabs that look like indentation" {
    try runTest("DK95/08");
}

// test "DMG6 - Wrong indendation in Map" {
//     try runTest("DMG6");
// }

// test "DWX9 - Spec Example 8.8. Literal Content" {
//     try runTest("DWX9");
// }

// test "E76Z - Aliases in Implicit Block Mapping" {
//     try runTest("E76Z");
// }

// test "EB22 - Missing document-end marker before directive" {
//     try runTest("EB22");
// }

// test "EHF6 - Tags for Flow Objects" {
//     try runTest("EHF6");
// }

// test "EW3V - Wrong indendation in mapping" {
//     try runTest("EW3V");
// }

// test "EX5H - Multiline Scalar at Top Level [1.3]" {
//     try runTest("EX5H");
// }

// test "EXG3 - Three dashes and content without space [1.3]" {
//     try runTest("EXG3");
// }

// test "F2C7 - Anchors and Tags" {
//     try runTest("F2C7");
// }

// test "F3CP - Nested flow collections on one line" {
//     try runTest("F3CP");
// }

// test "F6MC - More indented lines at the beginning of folded block scalars" {
//     try runTest("F6MC");
// }

// test "F8F9 - Spec Example 8.5. Chomping Trailing Lines" {
//     try runTest("F8F9");
// }

// test "FBC9 - Allowed characters in plain scalars" {
//     try runTest("FBC9");
// }

// test "FH7J - Tags on Empty Scalars" {
//     try runTest("FH7J");
// }

// test "FP8R - Zero indented block scalar" {
//     try runTest("FP8R");
// }

test "FQ7F - Spec Example 2.1. Sequence of Scalars" {
    try runTest("FQ7F");
}

// test "FRK4 - Spec Example 7.3. Completely Empty Flow Nodes" {
//     try runTest("FRK4");
// }

// test "FTA2 - Single block sequence with anchor and explicit document start" {
//     try runTest("FTA2");
// }

// test "FUP4 - Flow Sequence in Flow Sequence" {
//     try runTest("FUP4");
// }

// test "G4RS - Spec Example 2.17. Quoted Scalars" {
//     try runTest("G4RS");
// }

// test "G5U8 - Plain dashes in flow sequence" {
//     try runTest("G5U8");
// }

test "G7JE - Multiline implicit keys" {
    try runTest("G7JE");
}

// test "G992 - Spec Example 8.9. Folded Scalar" {
//     try runTest("G992");
// }

test "G9HC - Invalid anchor in zero indented sequence" {
    try runTest("G9HC");
}

test "GDY7 - Comment that looks like a mapping key" {
    try runTest("GDY7");
}

// test "GH63 - Mixed Block Mapping (explicit to implicit)" {
//     try runTest("GH63");
// }

test "GT5M - Node anchor in sequence" {
    try runTest("GT5M");
}

// test "H2RW - Blank lines" {
//     try runTest("H2RW");
// }

// test "H3Z8 - Literal unicode" {
//     try runTest("H3Z8");
// }

test "H7J7 - Node anchor not indented" {
    try runTest("H7J7");
}

// test "H7TQ - Extra words on %YAML directive" {
//     try runTest("H7TQ");
// }

// test "HM87/00 - Scalars in flow start with syntax char" {
//     try runTest("HM87/00");
// }

// test "HM87/01 - Scalars in flow start with syntax char" {
//     try runTest("HM87/01");
// }

// test "HMK4 - Spec Example 2.16. Indentation determines scope" {
//     try runTest("HMK4");
// }

// test "HMQ5 - Spec Example 6.23. Node Properties" {
//     try runTest("HMQ5");
// }

test "HRE5 - Double quoted scalar with escaped single quote" {
    try runTest("HRE5");
}

// test "HS5T - Spec Example 7.12. Plain Lines" {
//     try runTest("HS5T");
// }

// test "HU3P - Invalid Mapping in plain scalar" {
//     try runTest("HU3P");
// }

// test "HWV9 - Document-end marker" {
//     try runTest("HWV9");
// }

// test "J3BT - Spec Example 5.12. Tabs and Spaces" {
//     try runTest("J3BT");
// }

test "J5UC - Multiple Pair Block Mapping" {
    try runTest("J5UC");
}

// test "J7PZ - Spec Example 2.26. Ordered Mappings" {
//     try runTest("J7PZ");
// }

// test "J7VC - Empty Lines Between Mapping Elements" {
//     try runTest("J7VC");
// }

// test "J9HZ - Spec Example 2.9. Single Document with Two Comments" {
//     try runTest("J9HZ");
// }

// test "JEF9/00 - Trailing whitespace in streams" {
//     try runTest("JEF9/00");
// }

// test "JEF9/01 - Trailing whitespace in streams" {
//     try runTest("JEF9/01");
// }

// test "JEF9/02 - Trailing whitespace in streams" {
//     try runTest("JEF9/02");
// }

// test "JHB9 - Spec Example 2.7. Two Documents in a Stream" {
//     try runTest("JHB9");
// }

test "JKF3 - Multiline unidented double quoted block key" {
    try runTest("JKF3");
}

// test "JQ4R - Spec Example 8.14. Block Sequence" {
//     try runTest("JQ4R");
// }

// test "JR7V - Question marks in scalars" {
//     try runTest("JR7V");
// }

// test "JS2J - Spec Example 6.29. Node Anchors" {
//     try runTest("JS2J");
// }

// test "JTV5 - Block Mapping with Multiline Scalars" {
//     try runTest("JTV5");
// }

test "JY7Z - Trailing content that looks like a mapping" {
    try runTest("JY7Z");
}

// test "K3WX - Colon and adjacent value after comment on next line" {
//     try runTest("K3WX");
// }

test "K4SU - Multiple Entry Block Sequence" {
    try runTest("K4SU");
}

// test "K527 - Spec Example 6.6. Line Folding" {
//     try runTest("K527");
// }

// test "K54U - Tab after document header" {
//     try runTest("K54U");
// }

// test "K858 - Spec Example 8.6. Empty Scalar Chomping" {
//     try runTest("K858");
// }

test "KH5V/00 - Inline tabs in double quoted" {
    try runTest("KH5V/00");
}

// test "KH5V/01 - Inline tabs in double quoted" {
//     try runTest("KH5V/01");
// }

// test "KH5V/02 - Inline tabs in double quoted" {
//     try runTest("KH5V/02");
// }

// test "KK5P - Various combinations of explicit block mappings" {
//     try runTest("KK5P");
// }

test "KMK3 - Block Submapping" {
    try runTest("KMK3");
}

test "KS4U - Invalid item after end of flow sequence" {
    try runTest("KS4U");
}

// test "KSS4 - Scalars on --- line" {
//     try runTest("KSS4");
// }

// test "L24T/00 - Trailing line of spaces" {
//     try runTest("L24T/00");
// }

// test "L24T/01 - Trailing line of spaces" {
//     try runTest("L24T/01");
// }

// test "L383 - Two scalar docs with trailing comments" {
//     try runTest("L383");
// }

// test "L94M - Tags in Explicit Mapping" {
//     try runTest("L94M");
// }

// test "L9U5 - Spec Example 7.11. Plain Implicit Keys" {
//     try runTest("L9U5");
// }

// test "LE5A - Spec Example 7.24. Flow Nodes" {
//     try runTest("LE5A");
// }

test "LHL4 - Invalid tag" {
    try runTest("LHL4");
}

// test "LP6E - Whitespace After Scalars in Flow" {
//     try runTest("LP6E");
// }

// test "LQZ7 - Spec Example 7.4. Double Quoted Implicit Keys" {
//     try runTest("LQZ7");
// }

// test "LX3P - Implicit Flow Mapping Key on one line" {
//     try runTest("LX3P");
// }

// test "M29M - Literal Block Scalar" {
//     try runTest("M29M");
// }

// test "M2N8/00 - Question mark edge cases" {
//     try runTest("M2N8/00");
// }

// test "M2N8/01 - Question mark edge cases" {
//     try runTest("M2N8/01");
// }

// test "M5C3 - Spec Example 8.21. Block Scalar Nodes" {
//     try runTest("M5C3");
// }

// test "M5DY - Spec Example 2.11. Mapping between Sequences" {
//     try runTest("M5DY");
// }

// test "M6YH - Block sequence indentation" {
//     try runTest("M6YH");
// }

// test "M7A3 - Spec Example 9.3. Bare Documents" {
//     try runTest("M7A3");
// }

// test "M7NX - Nested flow collections" {
//     try runTest("M7NX");
// }

// test "M9B4 - Spec Example 8.7. Literal Scalar" {
//     try runTest("M9B4");
// }

// test "MJS9 - Spec Example 6.7. Block Folding" {
//     try runTest("MJS9");
// }

// test "MUS6/00 - Directive variants" {
//     try runTest("MUS6/00");
// }

// test "MUS6/01 - Directive variants" {
//     try runTest("MUS6/01");
// }

// test "MUS6/02 - Directive variants" {
//     try runTest("MUS6/02");
// }

// test "MUS6/03 - Directive variants" {
//     try runTest("MUS6/03");
// }

// test "MUS6/04 - Directive variants" {
//     try runTest("MUS6/04");
// }

// test "MUS6/05 - Directive variants" {
//     try runTest("MUS6/05");
// }

// test "MUS6/06 - Directive variants" {
//     try runTest("MUS6/06");
// }

// test "MXS3 - Flow Mapping in Block Sequence" {
//     try runTest("MXS3");
// }

// test "MYW6 - Block Scalar Strip" {
//     try runTest("MYW6");
// }

// test "MZX3 - Non-Specific Tags on Scalars" {
//     try runTest("MZX3");
// }

// test "N4JP - Bad indentation in mapping" {
//     try runTest("N4JP");
// }

test "N782 - Invalid document markers in flow style" {
    try runTest("N782");
}

test "NAT4 - Various empty or newline only quoted strings" {
    try runTest("NAT4");
}

// test "NB6Z - Multiline plain value with tabs on empty lines" {
//     try runTest("NB6Z");
// }

// test "NHX8 - Empty Lines at End of Document" {
//     try runTest("NHX8");
// }

// test "NJ66 - Multiline plain flow mapping key" {
//     try runTest("NJ66");
// }

// test "NKF9 - Empty keys in block and flow mapping" {
//     try runTest("NKF9");
// }

// test "NP9H - Spec Example 7.5. Double Quoted Line Breaks" {
//     try runTest("NP9H");
// }

// test "P2AD - Spec Example 8.1. Block Scalar Header" {
//     try runTest("P2AD");
// }

// test "P2EQ - Invalid sequene item on same line as previous item" {
//     try runTest("P2EQ");
// }

// test "P76L - Spec Example 6.19. Secondary Tag Handle" {
//     try runTest("P76L");
// }

// test "P94K - Spec Example 6.11. Multi-Line Comments" {
//     try runTest("P94K");
// }

// test "PBJ2 - Spec Example 2.3. Mapping Scalars to Sequences" {
//     try runTest("PBJ2");
// }

// test "PRH3 - Spec Example 7.9. Single Quoted Lines" {
//     try runTest("PRH3");
// }

// test "PUW8 - Document start on last line" {
//     try runTest("PUW8");
// }

// test "PW8X - Anchors on Empty Scalars" {
//     try runTest("PW8X");
// }

test "Q4CL - Trailing content after quoted value" {
    try runTest("Q4CL");
}

// test "Q5MG - Tab at beginning of line followed by a flow mapping" {
//     try runTest("Q5MG");
// }

// test "Q88A - Spec Example 7.23. Flow Content" {
//     try runTest("Q88A");
// }

// test "Q8AD - Spec Example 7.5. Double Quoted Line Breaks [1.3]" {
//     try runTest("Q8AD");
// }

// test "Q9WF - Spec Example 6.12. Separation Spaces" {
//     try runTest("Q9WF");
// }

// test "QB6E - Wrong indented multiline quoted scalar" {
//     try runTest("QB6E");
// }

// test "QF4Y - Spec Example 7.19. Single Pair Flow Mappings" {
//     try runTest("QF4Y");
// }

test "QLJ7 - Tag shorthand used in documents but only defined in the first" {
    try runTest("QLJ7");
}

// test "QT73 - Comment and document-end marker" {
//     try runTest("QT73");
// }

// test "R4YG - Spec Example 8.2. Block Indentation Indicator" {
//     try runTest("R4YG");
// }

// test "R52L - Nested flow mapping sequence and mappings" {
//     try runTest("R52L");
// }

test "RHX7 - YAML directive without document end marker" {
    try runTest("RHX7");
}

// test "RLU9 - Sequence Indent" {
//     try runTest("RLU9");
// }

// test "RR7F - Mixed Block Mapping (implicit to explicit)" {
//     try runTest("RR7F");
// }

// test "RTP8 - Spec Example 9.2. Document Markers" {
//     try runTest("RTP8");
// }

// test "RXY3 - Invalid document-end marker in single quoted string" {
//     try runTest("RXY3");
// }

// test "RZP5 - Various Trailing Comments [1.3]" {
//     try runTest("RZP5");
// }

// test "RZT7 - Spec Example 2.28. Log File" {
//     try runTest("RZT7");
// }

// test "S3PD - Spec Example 8.18. Implicit Block Mapping Entries" {
//     try runTest("S3PD");
// }

test "S4GJ - Invalid text after block scalar indicator" {
    try runTest("S4GJ");
}

// test "S4JQ - Spec Example 6.28. Non-Specific Tags" {
//     try runTest("S4JQ");
// }

// test "S4T7 - Document with footer" {
//     try runTest("S4T7");
// }

// test "S7BG - Colon followed by comma" {
//     try runTest("S7BG");
// }

test "S98Z - Block scalar with more spaces than first content line" {
    try runTest("S98Z");
}

// test "S9E8 - Spec Example 5.3. Block Structure Indicators" {
//     try runTest("S9E8");
// }

// test "SBG9 - Flow Sequence in Flow Mapping" {
//     try runTest("SBG9");
// }

test "SF5V - Duplicate YAML directive" {
    try runTest("SF5V");
}

// test "SKE5 - Anchor before zero indented sequence" {
//     try runTest("SKE5");
// }

// test "SM9W/00 - Single character streams" {
//     try runTest("SM9W/00");
// }

// test "SM9W/01 - Single character streams" {
//     try runTest("SM9W/01");
// }

test "SR86 - Anchor plus Alias" {
    try runTest("SR86");
}

// test "SSW6 - Spec Example 7.7. Single Quoted Characters [1.3]" {
//     try runTest("SSW6");
// }

// test "SU5Z - Comment without whitespace after doublequoted scalar" {
//     try runTest("SU5Z");
// }

test "SU74 - Anchor and alias as mapping key" {
    try runTest("SU74");
}

test "SY6V - Anchor before sequence entry on same line" {
    try runTest("SY6V");
}

// test "SYW4 - Spec Example 2.2. Mapping Scalars to Scalars" {
//     try runTest("SYW4");
// }

// test "T26H - Spec Example 8.8. Literal Content [1.3]" {
//     try runTest("T26H");
// }

// test "T4YY - Spec Example 7.9. Single Quoted Lines [1.3]" {
//     try runTest("T4YY");
// }

// test "T5N4 - Spec Example 8.7. Literal Scalar [1.3]" {
//     try runTest("T5N4");
// }

test "T833 - Flow mapping missing a separating comma" {
    try runTest("T833");
}

test "TD5N - Invalid scalar after sequence" {
    try runTest("TD5N");
}

// test "TE2A - Spec Example 8.16. Block Mappings" {
//     try runTest("TE2A");
// }

// test "TL85 - Spec Example 6.8. Flow Folding" {
//     try runTest("TL85");
// }

// test "TS54 - Folded Block Scalar" {
//     try runTest("TS54");
// }

// test "U3C3 - Spec Example 6.16. “TAG” directive" {
//     try runTest("U3C3");
// }

// test "U3XV - Node and Mapping Key Anchors" {
//     try runTest("U3XV");
// }

// test "U44R - Bad indentation in mapping (2)" {
//     try runTest("U44R");
// }

// test "U99R - Invalid comma in tag" {
//     try runTest("U99R");
// }

test "U9NS - Spec Example 2.8. Play by Play Feed from a Game" {
    try runTest("U9NS");
}

// test "UDM2 - Plain URL in flow mapping" {
//     try runTest("UDM2");
// }

// test "UDR7 - Spec Example 5.4. Flow Collection Indicators" {
//     try runTest("UDR7");
// }

// test "UGM3 - Spec Example 2.27. Invoice" {
//     try runTest("UGM3");
// }

// test "UKK6/00 - Syntax character edge cases" {
//     try runTest("UKK6/00");
// }

// test "UKK6/01 - Syntax character edge cases" {
//     try runTest("UKK6/01");
// }

// test "UKK6/02 - Syntax character edge cases" {
//     try runTest("UKK6/02");
// }

// test "UT92 - Spec Example 9.4. Explicit Documents" {
//     try runTest("UT92");
// }

// test "UV7Q - Legal tab after indentation" {
//     try runTest("UV7Q");
// }

// test "V55R - Aliases in Block Sequence" {
//     try runTest("V55R");
// }

// test "V9D5 - Spec Example 8.19. Compact Block Mappings" {
//     try runTest("V9D5");
// }

test "VJP3/00 - Flow collections over many lines" {
    try runTest("VJP3/00");
}

// test "VJP3/01 - Flow collections over many lines" {
//     try runTest("VJP3/01");
// }

// test "W42U - Spec Example 8.15. Block Sequence Entry Types" {
//     try runTest("W42U");
// }

// test "W4TN - Spec Example 9.5. Directives Documents" {
//     try runTest("W4TN");
// }

// test "W5VH - Allowed characters in alias" {
//     try runTest("W5VH");
// }

test "W9L4 - Literal block scalar with more spaces in first line" {
    try runTest("W9L4");
}

// test "WZ62 - Spec Example 7.2. Empty Content" {
//     try runTest("WZ62");
// }

// test "X38W - Aliases in Flow Objects" {
//     try runTest("X38W");
// }

test "X4QW - Comment without whitespace after block scalar indicator" {
    try runTest("X4QW");
}

// test "X8DW - Explicit key and value seperated by comment" {
//     try runTest("X8DW");
// }

// test "XLQ9 - Multiline scalar that looks like a YAML directive" {
//     try runTest("XLQ9");
// }

// test "XV9V - Spec Example 6.5. Empty Lines [1.3]" {
//     try runTest("XV9V");
// }

// test "XW4D - Various Trailing Comments" {
//     try runTest("XW4D");
// }

// test "Y2GN - Anchor with colon in the middle" {
//     try runTest("Y2GN");
// }

test "Y79Y/000 - Tabs in various contexts" {
    try runTest("Y79Y/000");
}

// test "Y79Y/001 - Tabs in various contexts" {
//     try runTest("Y79Y/001");
// }

// test "Y79Y/002 - Tabs in various contexts" {
//     try runTest("Y79Y/002");
// }

test "Y79Y/003 - Tabs in various contexts" {
    try runTest("Y79Y/003");
}

// test "Y79Y/004 - Tabs in various contexts" {
//     try runTest("Y79Y/004");
// }

// test "Y79Y/005 - Tabs in various contexts" {
//     try runTest("Y79Y/005");
// }

// test "Y79Y/006 - Tabs in various contexts" {
//     try runTest("Y79Y/006");
// }

test "Y79Y/007 - Tabs in various contexts" {
    try runTest("Y79Y/007");
}

// test "Y79Y/008 - Tabs in various contexts" {
//     try runTest("Y79Y/008");
// }

test "Y79Y/009 - Tabs in various contexts" {
    try runTest("Y79Y/009");
}

// test "Y79Y/010 - Tabs in various contexts" {
//     try runTest("Y79Y/010");
// }

// test "YD5X - Spec Example 2.5. Sequence of Sequences" {
//     try runTest("YD5X");
// }

// test "YJV2 - Dash in flow sequence" {
//     try runTest("YJV2");
// }

// test "Z67P - Spec Example 8.21. Block Scalar Nodes [1.3]" {
//     try runTest("Z67P");
// }

// test "Z9M4 - Spec Example 6.22. Global Tag Prefix" {
//     try runTest("Z9M4");
// }

// test "ZCZ6 - Invalid mapping in plain single line value" {
//     try runTest("ZCZ6");
// }

// test "ZF4X - Spec Example 2.6. Mapping of Mappings" {
//     try runTest("ZF4X");
// }

// test "ZH7C - Anchors in Mapping" {
//     try runTest("ZH7C");
// }

// test "ZK9H - Nested top level flow mapping" {
//     try runTest("ZK9H");
// }

test "ZL4Z - Invalid nested mapping" {
    try runTest("ZL4Z");
}

// test "ZVH3 - Wrong indented sequence item" {
//     try runTest("ZVH3");
// }

// test "ZWK4 - Key with anchor after missing explicit mapping value" {
//     try runTest("ZWK4");
// }

test "ZXT5 - Implicit key followed by newline and adjacent value" {
    try runTest("ZXT5");
}
