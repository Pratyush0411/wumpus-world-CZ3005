# import pyswip
class Driver:

    def __init__(self):
        self.abbr = {
            'containsWumpus': 'W',
            'containsPortal': 'O',
            'wumpysAndPortal': 'U',
            'faceNorth': '^',
            'faceWest': '<',
            'faceEast': '>',
            'faceSouth': 'v',
            'nonVistedSafe': 's',
            'visitedSafe': 'S',
            'nothing': '?'
        }
        self.symbols = {
            1: {'confunded': '%', 'notConfunded': '.'},
            2: {'stench': '=', 'notStench': '.'},
            3: {'tingle': 'T', 'notTingle': '.'},
            4: {'agent': '-', 'noAgent': ' '},
            5: self.abbr,
            6: {'agent': '-', 'noAgent': ' '},
            7: {'glitter': '*', 'noGlitter': ' '},
            8: {'bumpOn': 'B', 'bumpOff': '.'},
            9: {'screamOn': '@', 'screamOff': '.'}
        }

        wall = [['#', '#', '#'],
                ['#', '#', '#'],
                ['#', '#', '#']
                ]

        self.map = \
            [
                [wall, wall, wall, wall, wall, wall],
                [wall, self.getCell('nothing'), self.getCell('nothing'), self.getCell(
                    'nothing'), self.getCell('nothing', _7='glitter'),  wall],
                [wall, self.getCell('containsPortal'), self.getCell(
                    'nothing', _2='stench', _3='tingle'), self.getCell('nothing'), self.getCell('nothing'), wall],
                [wall, self.getCell('nothing', _2='stench', _3='tingle'), self.getCell(
                    'containsWumpus'), self.getCell('nothing', _2='stench'), self.getCell('nothing', _3='tingle'), wall],
                [wall, self.getCell('nothing'), self.getCell(
                    'nothing', _2='stench'), self.getCell('nothing', _3='tingle'), self.getCell('containsPortal'), wall],
                [wall, self.getCell('nothing'), self.getCell(
                    'nothing'), self.getCell('nothing', _3='tingle'), self.getCell('containsPortal'), wall],
                [wall, wall, wall, wall, wall, wall]
            ]

    def getCell(self, X, _1='notConfunded', _2='notStench', _3='notTingle', _4='noAgent', _6='noAgent', _7='noGlitter', _8='bumpOff', _9='screamOff'):
        cell = \
            [
                [self.symbols[1][_1], self.symbols[2][_2], self.symbols[3][_3]],
                [self.symbols[4][_4], self.symbols[5][X], self.symbols[6][_6]],
                [self.symbols[7][_7], self.symbols[8][_8], self.symbols[9][_9]]
            ]
        return cell

    def printMap(self):
        for i in range(len(self.map)):
            for iter in range(3):
                for cell in self.map[i]:
                    for j in range(len(cell)):
                        print(cell[iter][j], end=' ')
                    print(end='  ')
                print()
            print()


d = Driver()
d.printMap()
