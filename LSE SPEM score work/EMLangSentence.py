import numpy as np

#possible spectral emissions given as (n, n_prime) which is (sender, reciever)
spectral_transitions = [(7, 6), (7, 5), (7, 4), (7, 3), (7, 2), (7, 1),
                              (6, 5), (6, 4), (6, 3), (6, 2), (6, 1),
                                      (5, 4), (5, 3), (5, 2), (5, 1),
                                              (4, 3), (4, 2), (4, 1),
                                                      (3, 2), (3, 1), 
                                                              (2, 1)]

#possible spectral width modulations
spectral_widths = ["normal", "doubly-ext", "UV-ext", "IR-ext", "UV-dim", "IR-dim"]

#possible spectral filtering
spectral_filters = ["none", "tri", "tri-inv", "lo", "hi", "bp"]


#possible sonic transitions given as [(n, n_prime), can_be_free]
sonic_transitions = [[(6, 2), False],
                     [(5, 2), True],
                     [(4, 2), False],
                     [(7, 3), False], 
                     [(6, 3), True],
                     [(7, 4), True],
                     [(7, 5), False], 
                     [(6, 4), False],
                     [(5, 3), False]]

#possible sonic amplitude modulations 
sonic_amps = ["up", "down", "spike"]

#possible gender transitions
gender_transitions = [(7, 1), (6, 1), (5, 1), (4, 1), (3, 1), (2, 1)]
possible_genders = [2, 3, 4, 5, 6, 7]

class Spectral:
    trans = None
    width = None
    filter = None
    
    def __init__(self, trans, width, filter):
        self.trans = trans
        self.width = width
        self.filter = filter 
    
    def __repr__(self):
        return str(self.trans) + " " + self.width + " " + self.filter
        
    def __str__(self):
        return str(self.trans) + " " + self.width + " " + self.filter
        
        
class Sonic:
    trans = None
    amp = None
    
    def __init__(self, trans, amp):
        self.trans = trans
        self.amp = amp
        
    def __repr__(self):
        return str(self.trans) + " " + self.amp
        
    def __str__(self):
        return str(self.trans) + " " + self.amp
        
        
class Morpheme:
    spectral = None
    sonic1 = None
    sonic2 = None
    sonic3 = None  #should be sonic 
    gender = None  #should be list []
    haptic = None
    
    def __init__(self, spectral, sonic1, gender, haptic, sonic2 = None, sonic3 = None):
        self.spectral = spectral 
        self.sonic1 = sonic1
        self.gender = gender 
        self.haptic = haptic
        if sonic2 is not None:
            self.sonic2 = sonic2
        if sonic3 is not None:
            self.sonic3 = sonic3
            
    def __repr__(self):
        string = ""
        string += 'spectral: ' + str(self.spectral) + "\n"
        string += 'sonic1: ' + str(self.sonic1) + "\n"
        
        if self.sonic2 is not None:
            string += 'sonic2: ' + str(self.sonic2) + "\n"
        if self.sonic3 is not None:
            string += 'sonic3: ' + str(self.sonic3) + "\n"
        string += 'gender: ' + str(self.gender) + "\n"
        string += 'haptic: ' + str(self.haptic) + "\n"
        return string


def generate_random_spectral():
    #get random transition
    #get random width
    #get random filter
    trans = spectral_transitions[np.random.randint(len(spectral_transitions))]
    width = np.random.choice(spectral_widths)
    filter = np.random.choice(spectral_filters)
    
    spectral = Spectral(trans, width, filter)
    return spectral

def generate_random_sonic():
    #get random transition
    #if it can be free, add free to the list
    #get random amp
    
    trans_bool = sonic_transitions[np.random.randint(len(sonic_transitions))]
    trans = trans_bool[0]
    free = trans_bool[1]
    
    possible_amps = sonic_amps.copy()
    if free:
        possible_amps.append("free")

    amp = np.random.choice(possible_amps)
    
    sonic = Sonic(trans, amp)
    return sonic 

def generate_random_gender(): #same as generating random haptic 
    gender = []
    
    num_genders = np.random.randint(7)
    gender_pool = possible_genders.copy()
    
    for i in range(num_genders):
        gender_chosen = np.random.choice(gender_pool)
        gender.append(gender_chosen)
        gender_pool.remove(gender_chosen)
        
    return gender


def generate_random_haptic():
    haptic = []
    num_haptic = np.random.randint(6)+1 #always need at least one haptic
    haptic_pool = possible_genders.copy()

    while num_haptic > 0 and len(haptic_pool) > 0:

        haptic_chosen_ind = np.random.choice(np.arange(len(spectral_transitions)))
        haptic_chosen = spectral_transitions[haptic_chosen_ind]

        if haptic_chosen[0] in haptic_pool and haptic_chosen[1] in haptic_pool: #input as a pair
            haptic.append(haptic_chosen)
            haptic_pool.remove(haptic_chosen[0])
            haptic_pool.remove(haptic_chosen[1])

        elif haptic_chosen[0] in haptic_pool and haptic_chosen[1] == 1: #input as single 
            haptic.append(haptic_chosen[0])
            haptic_pool.remove(haptic_chosen[0])

        num_haptic -= 1

    return haptic


def generate_random_morpheme():
    #make random spectral
    #make 1-3 random sonic
    #make random gender 
    #put it into morpheme 
    spectral = generate_random_spectral()
    sonic1 = generate_random_sonic()
    sonic2 = generate_random_sonic()
    while sonic2.trans == sonic1.trans:
        sonic2 = generate_random_sonic()
    sonic3 = generate_random_sonic() 
    while sonic3.trans == sonic2.trans or sonic3.trans == sonic1.trans:
        sonic3 = generate_random_sonic()
    
    num_sonic = np.random.randint(3, size=1)[0] + 1
    
    if num_sonic == 2:
        sonic3 = None
    elif num_sonic == 1:
        sonic3 = None
        sonic2 = None
        
    gender = generate_random_gender()
    haptic = generate_random_haptic()
        
    morpheme = Morpheme(spectral, sonic1, gender, haptic, sonic2 = sonic2, sonic3 = sonic3)
    return morpheme 

def generate_random_word(): 
    #make 6 morphemes 
    #put into a list 
    word = []
    for i in range(6):
        morph = generate_random_morpheme()
        word.append(morph)
    
    return word

def generate_random_sentence():
    #make 21 words
    #put into a list
    sentence = []
    for i in range(21):
        word = generate_random_word()
        sentence.append(word)
        
    return sentence