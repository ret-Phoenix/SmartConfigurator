
f = open('tmp\module.txt')
data = f.read()
f.close()

data = data.upper()
f = open('tmp\module.txt', 'w')
f.write(data)
f.close()