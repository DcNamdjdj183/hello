const fs = require('fs');
let lines = fs.readFileSync('ThreeOneOSFive/ContentView.swift', 'utf8').split('\n');

for (let i = 0; i < lines.length; i++) {
    if (lines[i].includes('com.garena.game.kgvn')) {
        lines[i] = '    AppTarget(name: "Liên Quân Mobile", bundleId: "com.garena.game.kgvn", iconName: "gamecontroller.fill"),';
    }
}

fs.writeFileSync('ThreeOneOSFive/ContentView.swift', lines.join('\n'), 'utf8');
