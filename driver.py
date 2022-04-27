import sys
from pyswip import Prolog
from pyswip import Functor, Variable, Query
from regex import W

assertz = Functor("assertz", 2)


class Driver:

    def __init__(self):
        self.dead = False
        self.bump = False
        self.scream = False
        self.confunded = True
        self.agent_abs_pos = [5, 2, 'rnorth']  # make it random
        self.abbr = {
            'containsWumpus': 'W',
            'containsPortal': 'O',
            'wumpusAndPortal': 'U',
            'faceNorth': '^',
            'faceWest': '<',
            'faceEast': '>',
            'faceSouth': 'v',
            'nonVisitedSafe': 's',
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

        if self.bump:
            percepts += "Bump-"
            percepts_arr.append("on")
        else:
            percepts += "B-"
            percepts_arr.append("off")

        if self.scream:
            percepts += "Scream-"
            percepts_arr.append("on")
        else:
            percepts += "S"
            percepts_arr.append("off")

        return percepts, percepts_arr

    def reposition_agent(self, current):
        self.bump = False
        self.scream = False
        self.confunded = False
        self.agent_abs_pos = [5, 2, 'rnorth']  # make it random
        self.agent_relative = [
            (current[0]['X'], current[0]['Y']), current[0]['D']]
        if self.agent_relative[1] == 'rnorth':
            dir = 'faceNorth'
        elif self.agent_relative[1] == 'rwest':
            dir = 'faceWest'
        elif self.agent_relative[1] == 'rsouth':
            dir = 'faceSouth'
        elif self.agent_relative[1] == 'reast':
            dir = 'faceEast'
        self.relative_map = \
            [
                [self.get_cell('nothing'), self.get_cell(
                    'nothing'), self.get_cell('nothing')],
                [self.get_cell('nothing'), self.get_cell(dir, _1='confunded', _4='agent',
                                                         _6='agent'), self.get_cell('nothing')],
                [self.get_cell('nothing'), self.get_cell(
                    'nothing'), self.get_cell('nothing')]
            ]
        # self.delta = [self.agent_relative[0] - self.agent_abs_pos[0],
        #               self.agent_relative[1] - self.agent_abs_pos[1]]

    def map_origin(self):
        sane_map = {}
        i = 0
        j = 0

        n = len(self.relative_map)//2

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

    def get_adj(self, x, y):
        adj_list = [(x+1, y), (x, y+1), (x-1, y), (x, y-1)]
        return adj_list

    def update_relative_map(self, last, prolog):
        n = len(self.relative_map)
        if last and not self.bump:
            for i in range(n):
                self.relative_map[i].insert(0, self.get_cell('nothing'))
                self.relative_map[i].append(self.get_cell('nothing'))
            self.relative_map.append(
                [self.get_cell('nothing')]*(n+2))
            self.relative_map.insert(
                0, [self.get_cell('nothing')]*(n+2))

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
        # print("wumpus, confundus, glitter, stench, agent, visited_safe")
        # print()
        # print("visited(X,Y)", visited_safe)
        # print("wumpus(X,Y): ", wumpus)
        # print("confundus(X,Y):", confundus)
        # print("tingle(X,Y): ", tingle)
        # print("glitter(X,Y): ", glitter)
        # print("stench(X,Y): ", stench)
        print("agent relative position: ", agent)
        # print("wall(X,Y): ", wall)
        # print()
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

        if self.reposition_agent in wumpus_at:
            self.dead = True

        if self.reposition_agent in confundus_at:
            self.confunded = True

        unvisited_safe = []
        for node in visited_safe:
            adj_list = self.get_adj(node['X'], node['Y'])
            for neighbour in adj_list:
                if bool(prolog.query(f"safe({neighbour[0]},{neighbour[1]})")) and neighbour not in unvisited_safe and neighbour not in visited_at:
                    unvisited_safe.append(map[neighbour])

        for i in range(len(self.relative_map)):
            for j in range((len(self.relative_map[i]))):
                if (i, j) in wall_at:
                    self.relative_map[i][j] = self.wall
                    continue

                X = 'nothing'

                if (i, j) in visited_at:
                    X = 'visitedSafe'

                elif (i, j) in unvisited_safe:
                    X = 'nonVisitedSafe'

                if self.confunded:
                    _1 = 'confunded'
                else:
                    _1 = 'notConfunded'

                if (i, j) in confundus_at:
                    X = 'containsPortal'

                if (i, j) in stench_at:
                    _2 = 'stench'
                else:
                    _2 = 'notStench'

                if (i, j) in tingle_at:
                    _3 = 'tingle'
                else:
                    _3 = 'notTingle'

                if (i, j) in wumpus_at or (i, j) == self.agent_relative[0]:
                    _4 = 'agent'

                    if (i, j) in wumpus_at:
                        if (i, j) in confundus_at:
                            X = 'wumpusAndPortal'
                        else:
                            X = 'containsWumpus'
                    if (i, j) == self.agent_relative[0]:
                        D = self.agent_relative[1]
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

                if self.bump and (i, j) == self.agent_relative[0]:
                    _8 = 'bumpOn'
                else:
                    _8 = 'bumpOff'

                if self.scream:
                    _9 = 'screamOn'
                else:
                    _9 = 'screamOff'

                _4 = _6
                self.relative_map[i][j] = self.get_cell(
                    X, _1, _2, _3, _4, _6, _7, _8, _9)

    def move_agent(self, agent_location, action, abs=True):

        if action == 'shoot':
            self.scream = True

        if action != 'shoot':
            self.scream = False

        if action != 'moveforward':
            self.bump = False

        if action == 'moveforward':
            if agent_location[2] == 'rsouth':
                if agent_location[0] + 1 < len(self.map) and abs and self.map[agent_location[0] + 1][agent_location[1]] == self.wall:
                    self.bump = True
                else:
                    agent_location[0] += 1

            elif agent_location[2] == 'rnorth':
                if (agent_location[0] - 1 >= 0 and abs and self.map[agent_location[0] - 1][agent_location[1]] == self.wall):
                    self.bump = True
                else:
                    agent_location[0] -= 1

            elif agent_location[2] == 'reast':
                if (agent_location[1]+1 < len(self.map[0]) and abs and self.map[agent_location[0]][agent_location[1]+1] == self.wall):
                    self.bump = True
                else:
                    agent_location[1] += 1

            elif agent_location[2] == 'rwest':
                if (agent_location[1]-1 >= 0 and abs and self.map[agent_location[0]][agent_location[1] - 1] == self.wall):
                    self.bump = True
                else:
                    agent_location[1] -= 1

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

        prolog = Prolog()
        prolog.consult("agent.pl")
        # Reborn agent
        list(prolog.query("reborn"))

        # has agent returned to original position
        returned = False

        # confundus is turned on at the start of the game
        percepts, percepts_arr = self.get_percepts(
            self.agent_abs_pos[0], self.agent_abs_pos[1])
        percepts_arr[0] = "on"

        # call reposition function
        list(prolog.query(f"reposition({percepts_arr})"))
        current = list(prolog.query('current(X,Y,D)'))
        self.reposition_agent(current)
        self.print_map(self.relative_map)
        explore = True

        while(not returned and explore):

            if not bool(prolog.query("explore(L)")):
                explore = False
                break

            seq_actions = list(prolog.query("explore(L)"))
            if (len(seq_actions) == 0):
                break
            seq_actions = seq_actions[0]['L']
            print('The sequence of actions is: ')
            for a in range(len(seq_actions)):
                if a != len(seq_actions) - 1:
                    print(seq_actions[a], end=', ')
                else:
                    print(seq_actions[a])

            print()
            i = -1
            last = False

            for act in seq_actions:
                i += 1
                self.agent_abs_pos = self.move_agent(self.agent_abs_pos, act)
                percepts, percepts_arr = self.get_percepts(
                    self.agent_abs_pos[0], self.agent_abs_pos[1])
                print(f"Executing action: {act}")
                list(prolog.query(f"move({act},{percepts_arr})"))

                if i == len(seq_actions)-1:
                    last = True
                if (percepts_arr[3] == 'on'):
                    percepts, percepts_arr = self.get_percepts(
                        self.agent_abs_pos[0], self.agent_abs_pos[1])
                    print(f"Executing action: pickup")
                    list(prolog.query(f"move(pickup, {percepts_arr})"))

                # check if agent met wumpus and take required actions
                if self.dead:
                    self.run_agent()

                if self.confunded:
                    # call reposition function
                    list(prolog.query(f"reposition({percepts_arr})"))
                    current = list(prolog.query('current(X,Y,D)'))
                    self.reposition_agent(current)
                    print("reposition successful")

                self.update_relative_map(last, prolog)
                print('Percepts: ', percepts)
                self.print_map(self.relative_map)
                if(self.bump):
                    self.bump = False
                print()

            if self.agent_relative[0] == 0 and self.agent_relative[1] == 0:
                returned = True


print()

while (True):

    print('---------WELCOME TO WUMPUS WORLD------')
    print('Select an option from the following: ')
    print('1. Start Game')
    print('2. View Absolute Map')
    print('3. Exit Game')
    opt = int(input())
    d = Driver()
    if opt == 1:
        print('------------- ABSOLUTE MAP ------------------')
        d.print_map(d.map)
        print('-------------- GAME BEGINS ------------------')
        d.run_agent()

    elif opt == 2:
        print('------------- ABSOLUTE MAP ------------------')
        d.print_map(d.map)

    else:
        break
