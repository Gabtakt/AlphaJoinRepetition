import os

encodepath1 = '../test/queryEncode1'
encodepath2 = '../test/queryEncode2'

def checkEncode():
    encodeDict1 = {}
    encodeDict2 = {}
    f = open(encodepath1, 'r')
    a = f.read()
    encodeDict1 = eval(a)
    f.close()

    f = open(encodepath2, 'r')
    a = f.read()
    encodeDict2 = eval(a)
    f.close()

    for K,V in encodeDict1.items():
        V2 = encodeDict2[K]
        for i in range(0,len(V)):
            if V[i] != 0:
                print(V[i],V2[i])
                assert(V2[i] != 0)

    # print(encodeDict1)
    # print(encodeDict2)


if __name__ == '__main__':
    checkEncode()
