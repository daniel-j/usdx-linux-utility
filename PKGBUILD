# Maintainer: djazz

pkgname=ultrastardx-manager
pkgver=0.1
pkgrel=1
pkgdesc="Manages UltraStar Deluxe songs."
arch=('any')
url="https://usdx.eu/"
license=('GPL')
depends=('zenity')
optdepends=(
  'ultrastardx: UltraStar Deluxe'
  'imagemagick: Thumbnail generator'
)
source=(
  usdx-open.sh
  prompt.html
  usdx-open.desktop
  usdx-open.mime.xml
  usdx-thumbnailer.sh
  usdx.thumbnailer
)
sha1sums=(
  'SKIP'
  'SKIP'
  'SKIP'
  'SKIP'
  'SKIP'
  'SKIP'
)

#pkgver() {
#  cd "$pkgname"
#  printf "r%s.%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short HEAD)"
#}

build() {
  echo
}

package() {
  install -d "$pkgdir/usr/share/${pkgname}"
  install "${srcdir}/prompt.html" "$pkgdir/usr/share/${pkgname}/prompt.html"

  # applications
  install -d "${pkgdir}/usr/share/applications"
  install "${srcdir}/usdx-open.desktop" "${pkgdir}/usr/share/applications/usdx-open.desktop"

  # bin
  install -d "${pkgdir}/usr/bin"
  install "${srcdir}/usdx-open.sh" "${pkgdir}/usr/bin/usdx-open"
  install "${srcdir}/usdx-thumbnailer.sh" "${pkgdir}/usr/bin/usdx-thumbnailer"

  # mime
  install -d "${pkgdir}/usr/share/mime/packages/"
  install "${srcdir}/usdx-open.mime.xml" "${pkgdir}/usr/share/mime/packages/usdx-open.xml"

  # thumbnailer
  install -d "${pkgdir}/usr/share/thumbnailers/"
  install "${srcdir}/usdx.thumbnailer" "${pkgdir}/usr/share/thumbnailers/usdx.thumbnailer"

  # Icon
  #install -d "${pkgdir}/usr/share/pixmaps"
  #install "${srcdir}/${pkgname}/app/media/icons/JCS.png" "${pkgdir}/usr/share/pixmaps/${pkgname}.png"

  # Register mimetypes
  
}
