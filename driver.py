from pyswip import Prolog
from pyswip import Functor, Variable, Query

assertz = Functor("assertz", 2)


class Driver:

    def __init__(self):

        self.abbr = {
            'containsWumpus': 'W',
            'containsPortal': 'O',
            'wumpusAndPortal': 'U',
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
            7: {'glitter': '*', 'noGlitter': '.'},
            8: {'bumpOn': 'B', 'bumpOff': '.'},
            9: {'screamOn': '@', 'screamOff': '.'}
        }

        self.wall = [['#', '#', '#'],
                     ['#', '#', '#'],
                     ['#', '#', '#']
                     ]

        self.map = \
            [
                [self.wall, self.wall, self.wall, self.wall, self.wall, self.wall],
                [self.wall, self.get_cell('nothing', _3='tingle'), self.get_cell('nothing'), self.get_cell(
                    'nothing'), self.get_cell('nothing', _7='glitter'),  self.wall],
                [self.wall, self.get_cell('containsPortal'), self.get_cell(
                    'nothing', _2='stench', _3='tingle'), self.get_cell('nothing'), self.get_cell('nothing'), self.wall],
                [self.wall, self.get_cell('nothing', _2='stench', _3='tingle'), self.get_cell(
                    'containsWumpus'), self.get_cell('nothing', _2='stench'), self.get_cell('nothing', _3='tingle'), self.wall],
                [self.wall, self.get_cell('nothing'), self.get_cell(
                    'nothing', _2='stench'), self.get_cell('nothing', _3='tingle'), self.get_cell('containsPortal', _3='tingle'), self.wall],
                [self.wall, self.get_cell('nothing'), self.get_cell(
                    'nothing'), self.get_cell('nothing', _3='tingle'), self.get_cell('containsPortal'), self.wall],
                [self.wall, self.wall, self.wall, self.wall, self.wall, self.wall]
            ]

    def get_cell(self, X, _1='notConfunded', _2='notStench', _3='notTingle', _4='noAgent', _6='noAgent', _7='noGlitter', _8='bumpOff', _9='screamOff'):
        cell = \
            [
                [self.symbols[1][_1], self.symbols[2][_2], self.symbols[3][_3]],
                [self.symbols[4][_4], self.symbols[5][X], self.symbols[6][_6]],
                [self.symbols[7][_7], self.symbols[8][_8], self.symbols[9][_9]]
            ]
        return cell

    def print_map(self, map):
        print()
        for i in range(len(map)):
            for iter in range(3):
                for cell in map[i]:
                    for j in range(len(cell)):
                        print(cell[iter][j], end=' ')
                    print(end='  ')
                print()
            print()

    def get_percepts(self, x, y):
        percepts_arr = []
        percepts = ""
        print('x,y=', x, y)
        if self.bump:
            cell = self.wall
        else:
            cell = self.map[x][y]
        if cell[0][0] == '%':
            percept += "Confunded-"
            percepts_arr.append("on")
        else:
            percepts += "C-"
            percepts_arr.append("off")

        if cell[0][1] == '=':
            percepts += "Stench-"
            percepts_arr.append("on")
        else:
            percepts += "S-"
            percepts_arr.append("off")

        if cell[0][2] == 'T':
            percepts += "Tingle-"
            percepts_arr.append("on")
        else:
            percepts += "T-"
            percepts_arr.append("off")

        if cell[2][0] == '*':
            percepts += "Glitter-"
            percepts_arr.append("on")
            cell[2][0] == '.'  # remove glitter from map
        else:
            percepts += "G-"
            percepts_arr.append("off")

        if self.bump or cell[2][1] == '#' or cell[2][1] == 'B':
            percepts += "Bump-"
            percepts_arr.append("on")
        else:
            percepts += "B-"
            percepts_arr.append("off")

        if self.scream or cell[2][2] == '@':
            percepts += "Scream-"
            percepts_arr.append("on")
        else:
            percepts += "S"
            percepts_arr.append("off")

        return percepts, percepts_arr

    def reposition_agent(self):
        self.bump = False
        self.scream = False
        self.confunded = True
        self.agent_abs_pos = [5, 2, 'rnorth']  # make it random
        self.relative_map = \
            [
                [self.get_cell('nothing'), self.get_cell(
                    'nothing'), self.get_cell('nothing')],
                [self.get_cell('nothing'), self.get_cell(
                    'faceSouth', _6='agent'), self.get_cell('nothing')],
                [self.get_cell('nothing'), self.get_cell(
                    'nothing'), self.get_cell('nothing')]
            ]
        self.agent_relative = [
            len(self.relative_map)//2, len(self.relative_map)//2, 'rnorth']
        self.delta = [self.agent_relative[0] - self.agent_abs_pos[0],
                      self.agent_relative[1] - self.agent_abs_pos[1]]

    def map_origin(self):
        sane_map = {}
        i = 0
        j = 0
        print('len:', len(self.relative_map))

        n = len(self.relative_map)//2 - 1
        print('n:', n)
        r = n
        c = -n
        while r >= -n:
            j = 0
            c = -n
            while c < n:
                sane_map[(c, r)] = (i, j)
                j += 1
                c += 1

            r -= 1
            i += 1

        return sane_map

    def update_relative_map(self, act, prolog):

        if act == 'moveforward':
            self.relative_map.append(
                [self.get_cell('nothing')]*(len(self.relative_map)+2))
            self.relative_map.insert(
                0, [self.get_cell('nothing')]*(len(self.relative_map)+2))

        wumpus = list(prolog.query("wumpus(X,Y)"))
        confundus = list(prolog.query("confundus(X,Y)"))
        glitter = list(prolog.query("glitter(X,Y)"))
        stench = list(prolog.query("stench(X,Y)"))
        agent = list(prolog.query("current(X,Y,D)"))
        visited_safe = list(prolog.query("visited(X,Y)"))
        wall = list(prolog.query("wall(X,Y)"))
        tingle = list(prolog.query("tingle(X,Y)"))

        map = self.map_origin()
        self.agent_relative = (
            map[(agent[0]['X'], agent[0]['Y'])], agent[0]['D'])
        print(self.agent_relative)
        print(wumpus, confundus, glitter, stench, agent, visited_safe)
        map = self.map_origin()

        wumpus_at = []
        for point in wumpus:
            wumpus_at.append(map[(point['X'], point['Y'])])

        confundus_at = []
        for point in confundus:
            confundus_at.append(map[(point['X'], point['Y'])])

        glitter_at = []
        for point in glitter:
            glitter_at.append(map[(point['X'], point['Y'])])

        stench_at = []
        for point in stench:
            stench_at.append(map[(point['X'], point['Y'])])

        visited_at = []
        for point in visited_safe:
            visited_at.append(map[(point['X'], point['Y'])])

        wall_at = []
        for point in wall:
            wall_at.append(map[(point['X'], point['Y'])])

        tingle_at = []
        for point in tingle:
            tingle_at.append(map[(point['X'], point['Y'])])

        for i in range(len(self.relative_map)):
            for j in range((len(self.relative_map[i]))):
                if (i, j) in wall_at:
                    self.relative_map[i][j] = self.wall
                    continue

                X = 'nothing'
                if (i, j) in confundus_at:
                    _1 = 'confounded'
                    X = 'conatinsPortal'
                else:
                    _1 = 'notConfunded'

                if (i, j) in stench_at:
                    _2 = 'stench'
                else:
                    _2 = 'notStench'

                if (i, j) in tingle_at:
                    _3 = 'tingle'
                else:
                    _3 = 'notTingle'

                if (i, j) in wumpus_at or (i, j) == self.agent_relative:
                    _4 = 'agent'

                    if (i, j) in wumpus_at:
                        if _1 == 'confunded':
                            X = 'wumpusAndPortal'
                        else:
                            X = 'wumpus'
                    if (i, j) == self.agent_relative:
                        print('agent_relative = ', self.agent_relative)
                        D = self.agent_relative[2]
                        if D == 'rnorth':
                            X = 'faceNorth'
                        elif D == 'reast':
                            X = 'faceEast'
                        elif D == 'rsouth':
                            X = 'faceSouth'
                        elif D == 'rwest':
                            X = 'faceWest'
                else:
                    _4 = 'noAgent'

                _6 = _4

                if (i, j) in glitter_at:
                    _7 = 'glitter'
                else:
                    _7 = 'noGlitter'

                if (i, j) in glitter_at:
                    _7 = 'Glitter'
                else:
                    _7 = 'noGlitter'

                if self.bump:
                    _8 = 'bumpOn'
                else:
                    _8 = 'bumpOff'

                if self.scream:
                    _9 = 'screamOn'
                else:
                    _9 = 'screamOff'

                self.relative_map[i][j] = self.get_cell(
                    X, _1, _2, _3, _4, _6, _7, _8, _9)

        # self.print_map(self.relative_map)

    def move_agent(self, agent_location, action, abs=True):
        print('agent location = ', agent_location)
        print('abs = ', abs)
        if action == 'shoot':
            self.scream = True

        if action == 'moveforward':
            if agent_location[2] == 'rnorth':
                if agent_location[1] + 1 < len(self.map[0]) and abs and self.map[agent_location[0]][agent_location[1] + 1] == self.wall:
                    self.bump = True
                else:
                    agent_location[1] += 1
            elif agent_location[2] == 'rsouth':
                if (agent_location[1] - 1 >= 0 and abs and self.map[agent_location[0]][agent_location[1] - 1] == self.wall):
                    self.bump = True
                else:
                    agent_location[1] -= 1

            elif agent_location[2] == 'reast':
                if (agent_location[0]+1 < len(self.map[0]) and abs and self.map[agent_location[0]+1][agent_location[1]] == self.wall):
                    self.bump = True
                else:
                    agent_location[0] += 1

            elif agent_location[2] == 'rwest':
                if (agent_location[0]+1 >= 0 and abs and self.map[agent_location[0]-1][agent_location[1]] == self.wall):
                    self.bump = True
                else:
                    agent_location[0] -= 1

        elif action == 'turnright':
            if agent_location[2] == 'rnorth':
                agent_location[2] = 'reast'
            elif agent_location[2] == 'reast':
                agent_location[2] = 'rsouth'
            elif agent_location[2] == 'rsouth':
                agent_location[2] = 'rwest'
            elif agent_location[2] == 'rwest':
                agent_location[2] = 'rnorth'

        elif action == 'turnleft':
            if agent_location[2] == 'rnorth':
                agent_location[2] = 'rwest'
            elif agent_location[2] == 'reast':
                agent_location[2] = 'rnorth'
            elif agent_location[2] == 'rsouth':
                agent_location[2] = 'reast'
            elif agent_location[2] == 'rwest':
                agent_location[2] = 'rsouth'

        return agent_location

    def run_agent(self):
        self.reposition_agent()
        print("reposition successful")
        prolog = Prolog()
        prolog.consult("agent.pl")
        returned = False
        percepts, percepts_arr = self.get_percepts(
            self.agent_abs_pos[0], self.agent_abs_pos[1])
        percepts_arr[0] = "on"
        print(percepts_arr)
        print(bool(prolog.query(f"reposition({percepts_arr}).")))
        print(list(prolog.query("current(X,Y,D)")))
        turn = 0
        explore = True
        while(not returned and explore):
            if turn > 2:
                break
            turn += 1

            if not bool(prolog.query("explore(L)")):
                explore = False

            seq_actions = list(prolog.query("explore(L)"))
            seq_actions = seq_actions[0]['L']
            print(seq_actions)
            for act in seq_actions:
                self.update_relative_map(act, prolog)
                print(act, end='')
                self.agent_abs_pos = self.move_agent(self.agent_abs_pos, act)
                self.agent_relative = self.move_agent(
                    self.agent_abs_pos, act, abs=False)
                percepts, percepts_arr = self.get_percepts(
                    self.agent_abs_pos[0], self.agent_abs_pos[1])
                prolog.query(f"move({act},{percepts_arr})")
                print('percepts array', percepts_arr)
                # self.print_map(self.relative_map)
                if (percepts_arr[3] == 'on'):
                    percepts, percepts_arr = self.get_percepts(
                        self.agent_abs_pos[0], self.agent_abs_pos[1])
                    prolog.query(f"move(pickup, {percepts_arr})")
                    # self.print_map(self.relative_map)
                print()
            print(percepts)

            if self.agent_relative[0] == 0 and self.agent_relative[1] == 0:
                returned = True


print()
i = 1
while (i < 3):

    print('---------WELCOME TO WUMPUS WORLD------')
    print('Select an option from the following: ')
    print('1. Start Game')
    print('2. View Absolute Vodka')
    print('3. Exit Game')
    i += 1
    opt = int(input())
    d = Driver()
    if opt == 1:
        d.run_agent()

    elif opt == 2:
        d.print_map(d.map)

    else:
        break
