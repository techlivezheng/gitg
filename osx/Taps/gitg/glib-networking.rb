class GlibNetworking < Formula
  desc "Network related modules for glib"
  homepage "https://launchpad.net/glib-networking"
  url "https://download.gnome.org/sources/glib-networking/2.48/glib-networking-2.48.2.tar.xz"
  mirror "https://mirrors.kernel.org/debian/pool/main/g/glib-networking/glib-networking_2.48.2.orig.tar.xz"
  sha256 "925c0c49d6b2b8b5695f2e33cd952d1dbb7d18d3f2f796413577719315bb3a84"

  depends_on "pkg-config" => :build
  depends_on "intltool" => :build
  depends_on "gettext"
  depends_on "gnome/gitg/glib"
  depends_on "gnome/gitg/gnutls"
  depends_on "gnome/gitg/gsettings-desktop-schemas"

  link_overwrite "lib/gio/modules"

  def install
    # Install files to `lib` instead of `HOMEBREW_PREFIX/lib`.
    inreplace "configure", "$($PKG_CONFIG --variable giomoduledir gio-2.0)", lib/"gio/modules"
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--with-ca-certificates=#{etc}/openssl/cert.pem",
                          # Remove when p11-kit >= 0.20.7 builds on OSX
                          # see https://github.com/Homebrew/homebrew/issues/36323
                          # and https://bugs.freedesktop.org/show_bug.cgi?id=91602
                          "--without-pkcs11"
    system "make", "install"

    # Delete the cache, will regenerate it in post_install
    rm lib/"gio/modules/giomodule.cache"
  end

  def post_install
    system Formula["glib"].opt_bin/"gio-querymodules", HOMEBREW_PREFIX/"lib/gio/modules"
  end

  test do
    (testpath/"gtls-test.c").write <<-EOS.undent
      #include <gio/gio.h>
      int main (int argc, char *argv[])
      {
        if (g_tls_backend_supports_tls (g_tls_backend_get_default()))
          return 0;
        else
          return 1;
      }
    EOS

    # From `pkg-config --cflags --libs gio-2.0`
    flags = [
      "-D_REENTRANT",
      "-I#{HOMEBREW_PREFIX}/include/glib-2.0",
      "-I#{HOMEBREW_PREFIX}/lib/glib-2.0/include",
      "-I#{HOMEBREW_PREFIX}/opt/gettext/include",
      "-L#{HOMEBREW_PREFIX}/lib",
      "-L#{HOMEBREW_PREFIX}/opt/gettext/lib",
      "-lgio-2.0", "-lgobject-2.0", "-lglib-2.0", "-lintl"
    ]

    system ENV.cc, "gtls-test.c", "-o", "gtls-test", *flags
    system "./gtls-test"
  end
end
