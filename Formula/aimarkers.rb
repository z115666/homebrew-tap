class Aimarkers < Formula
  include Language::Python::Shebang

  desc "Detect AI markers in code, docs, websites, images and Git repositories"
  homepage "https://github.com/z115666/aimarkers"
  # Pinned to a specific commit: immutable, unlike a tag
  url "https://github.com/z115666/aimarkers/archive/9970a3c240f71097dd66cdb1d1129fdd90f1edc1.tar.gz"
  version "1.2.0"
  sha256 "836d4ac14b3ace41066b5a4e4598558252c9f05963fa66b1db636af35d5a37fc"
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
