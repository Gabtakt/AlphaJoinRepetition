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

    print(encodeDict1)
    print(encodeDict2)
