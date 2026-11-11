class Aimarkers < Formula
  include Language::Python::Shebang

  desc "Detect AI markers in code, docs, websites, images and Git repositories"
  homepage "https://github.com/z115666/aimarkers"
  # Pinned to a specific commit: immutable, unlike a tag
  url "https://github.com/z115666/aimarkers/archive/7b90604e020b275d19eb63e51bfd5e07e0cd4c34.tar.gz"
  version "1.2.1"
  sha256 "dd540062454213ba748da4110eabe46924b855e05f0ea9ac9b57f9552b2dc6d3"
  license "MIT"
  head "https://github.com/z115666/aimarkers.git", branch: "main"

  depends_on "python@3.15"

  def install
    libexec.install "aimarkers.py", "aimarkers_gui.py", "gui"
    rewrite_shebang detected_python_shebang, libexec/"aimarkers.py"
    bin.install_symlink libexec/"aimarkers.py" => "aimarkers"
    doc.install Dir["README*.md", "SECURITY*.md", "CHANGELOG*.md"]
  end

  def caveats
    <<~EOS
      Graphical interface / Interfaz gráfica:
        aimarkers --gui

      To verify C2PA (Content Credentials) signatures in images, also install:
        brew install c2patool
      Para verificar las firmas C2PA de las imágenes, instala también c2patool.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/aimarkers --version")
    assert_match "--gui", shell_output("#{bin}/aimarkers --help")
    assert_path_exists libexec/"gui/index.html"
    system libexec/"aimarkers.py", "--help"

    (testpath/"human.md").write "Notes from yesterday's meeting: check the proxy and close the ticket."
    assert_match "No relevant signs", shell_output("#{bin}/aimarkers #{testpath}/human.md --no-color --lang en")
    assert_match "Sin indicios relevantes", shell_output("#{bin}/aimarkers #{testpath}/human.md --no-color --lang es")

    (testpath/"ai.md").write "More information at https://example.com/?utm_source=chatgpt.com"
    assert_match "EXPLICIT ATTRIBUTION", shell_output("#{bin}/aimarkers #{testpath}/ai.md --no-color --lang en")
  end
end
