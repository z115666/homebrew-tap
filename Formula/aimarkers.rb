class Aimarkers < Formula
  include Language::Python::Shebang

  desc "Detecta marcadores de IA en código, documentación, webs y repositorios Git"
  homepage "https://github.com/z115666/aimarkers"
  # Fijado a un commit concreto: inmutable, a diferencia de una etiqueta
  url "https://github.com/z115666/aimarkers/archive/3775e699337af2166a1b90afcea3be533e018c06.tar.gz"
  version "1.0.0"
  sha256 "1298bd1b69d2794ad7514276176ce981374724448abcb848f3c03c0c3f93c0c6"
  license "MIT"
  head "https://github.com/z115666/aimarkers.git", branch: "main"

  depends_on "python@3.15"

  def install
    libexec.install "aimarkers.py"
    rewrite_shebang detected_python_shebang, libexec/"aimarkers.py"
    bin.install_symlink libexec/"aimarkers.py" => "aimarkers"
    doc.install "README.md", "SECURITY.md", "CHANGELOG.md"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/aimarkers --version")

    (testpath/"humano.md").write "Notas de la reunión de ayer: revisar el proxy y cerrar el ticket."
    assert_match "Sin indicios relevantes", shell_output("#{bin}/aimarkers #{testpath}/humano.md --sin-color")

    (testpath/"ia.md").write "Más información en https://example.com/?utm_source=chatgpt.com"
    assert_match "ATRIBUCIÓN EXPLÍCITA", shell_output("#{bin}/aimarkers #{testpath}/ia.md --sin-color")
  end
end
