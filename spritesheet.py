from PIL import Image
import os

carpeta = r'C:\Users\Daniela\Downloads\rezefinished'
cols = 8
filas = 7

imagenes = [Image.open(os.path.join(carpeta, f'{i}.png')) for i in range(1, 54)]
w, h = imagenes[0].size
sheet = Image.new('RGBA', (w * cols, h * filas), (0, 0, 0, 0))

for i, img in enumerate(imagenes):
    x = (i % cols) * w
    y = (i // cols) * h
    sheet.paste(img, (x, y))

sheet.save(r'C:\Users\Daniela\Downloads\rezefinished\spritesheet_reze.png')
print('Listo!')
