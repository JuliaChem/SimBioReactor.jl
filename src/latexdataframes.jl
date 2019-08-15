using DataFrames, Mustache, Dates
import DefaultApplication

df = DataFrame(label=1:4, score=2:5, max=4:7)

student = Dict( "name" => "John", "surname" => "Smith", "df" => df)

timenow = Dates.now()
timenow1 = Dates.format(timenow, "e, dd u yyyy HH:MM:SS")
marks_tmpl = """
\\documentclass{article}
\\usepackage[letterpaper, portrait, margin=1in]{geometry}
\\begin{document}
\\begin{center}
\\huge{\\textbf{SimBioReactor v1.0}}\n\n
\\rule{15cm}{0.05cm}\n\n\n
\\normalsize{Your marks are:}\n
  \\begin{tabular}{ |c|c|c| }
    \\hline
    cell1 & cell2 & cell3 \\cr
    cell4 & cell5 & cell6 \\cr
    cell7 & cell8 & cell9 \\cr
    \\hline\n\n\n
  \\end{tabular}
\\rule{15cm}{0.05cm}
\\end{center}
\\end{document}
"""

rendered = render(marks_tmpl, student)

filename = string("prueba.tex")
open(filename, "w") do file
  write(file, rendered)
end
run(`pdflatex $filename`)
DefaultApplication.open("prueba.pdf")
