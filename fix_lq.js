const fs = require('fs');
let text = fs.readFileSync('ThreeOneOSFive/ContentView.swift', 'utf8');

const regex = /AppTarget\(name:\s*".*?Mobile",\s*bundleId:\s*"com\.garena\.game\.kgvn"/g;
text = text.replace(regex, 'AppTarget(name: "Liên Quân Mobile", bundleId: "com.garena.game.kgvn"');

fs.writeFileSync('ThreeOneOSFive/ContentView.swift', text, 'utf8');
