module kicad.src.kicad;

import std.stdio;
import std.file;

void main(string[] args) {
    writeln(args);
    File(args[2], "w").write(pcb(readText(args[1])));
}

import pegged.grammar;

mixin(grammar(`
    pcb:
        kicad_pcb <  :l :'kicad_pcb' verzion generator general paper layers
        layers    <  :l :'layers' deflayer* :r
        deflayer  <  :l num layername ('signal'|'user') layername? :r
        layername <~ :'\"' [a-zA-Z]+.[a-zA-Z]+ :'\"'
        paper     <  :l :'paper' :'\"' 'A4' :'\"' :r
        general   <  :l :'general' thickness :r
        thickness <  :l :'thickness' num :r
        generator <  :l :'generator' 'pcbnew' :r
        verzion   <  :l :'version' num :r
        num       <~ [0-9]+(.[0-9]+)?
        id        <~ [a-z_][a-z_]*
        l         <  '('
        r         <  ')'
        any       <  .
`));
