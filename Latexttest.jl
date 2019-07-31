using Mustache

students = [
  Dict( "name" => "John", "surname" => "Smith", "marks" => [25, 32, 40, 38] ),
  Dict( "name" => "Elisa", "surname" => "White", "marks" => [40, 40, 36, 35] )
]

tmpl = """
\\documentclass{article}

\\begin{document}

Hello \\textbf{ {{name}}, {{surname}} }. Your marks are:
\\begin{itemize}
  {{#marks}}
    \\item Mark for question is {{.}}
  {{/marks}}
\\end{itemize}
\\end{document}
"""

for student in students
  rendered = render(tmpl, student)
  filename = string(pwd(),"\\", student["name"], "_", student["surname"], ".tex")
  open(filename, "w") do file
    write(file, rendered)
  end
  run(`pdflatex $filename`)
end
