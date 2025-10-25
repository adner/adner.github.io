### ImageMagick

Make image max 800 pixels wide:
`magick mogrify -resize "800x800>" *.png`

Optimize for web:
`magick mogrify -strip -interlace Plane -quality 85% *.png`

