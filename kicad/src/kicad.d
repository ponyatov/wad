module kicad.src.kicad;

import std.stdio;
import std.file;

void main(string[] args) {
    writeln(args);
    writeln(pcb(readText(args[1])));
}

import pegged.grammar;

mixin(grammar(`
    pcb:
        kicad_pcb <  :l :'kicad_pcb' verzion generator :r | (num|id|l|r|any)*
        generator <  :l :'generator' 'pcbnew' :r
        verzion   <  :l :'version' num :r
        num       <~ [0-9]+
        id        <~ [a-z_][a-z_]*
        l         <  '('
        r         <  ')'
        any       <  .
`));
