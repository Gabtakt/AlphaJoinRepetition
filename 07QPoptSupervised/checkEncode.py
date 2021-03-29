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

    # 检查one-hot编码有效部分跟histogram编码有效部分是否相同
    for K,V in encodeDict1.items():
        V2 = encodeDict2[K]
        for i in range(0,len(V)):
            if V[i] != 0:
                assert(V2[i] != 0)
            if V2[i] != 0:
                assert(V[i] != 0)

    # print(encodeDict1)
    # print(encodeDict2)


if __name__ == '__main__':
    checkEncode()
