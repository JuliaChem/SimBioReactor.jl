using Gtk, Gtk.ShortNames, GR, Printf, CSV, LsqFit, Distributions, Mustache
using DataFrames
import DefaultApplication, Dates


df = DataFrame(label=1:4, score=200:100:500, max=4:7)
fmt = string("|",repeat("c|", size(df,2)))
header = join(string.(names(df)), " & ")
row = join(["{{:$x}}" for x in map(string, names(df))], " & ")

timenow = Dates.now()
timenow1 = Dates.format(timenow, "dd u yyyy HH:MM:SS")

marks_tmpl = """
\\documentclass{article}
\\usepackage{graphicx}
\\graphicspath{ {C:/Windows/Temp/} }
\\usepackage[letterpaper, portrait, margin=1in]{geometry}
\\begin{document}
\\begin{center}
\\huge{\\textbf{SimBioReactor v1.0}}\n
\\vspace{3mm}
\\normalsize{{:time}}
\\vspace{3mm}
\\rule{15cm}{0.04cm}\n\n\n
\\normalsize{Your marks are:}\n
  \\vspace{3mm}
  \\begin{tabular}{$fmt}
    \\hline
    $header\\\\
    \\hline
    {{#:DF}} $row\\cr
    {{/:DF}}
  \\hline\n
  \\end{tabular}
  \\vspace{3mm}\n
\\rule{15cm}{0.04cm}\n
\\vspace{3mm}
\\includegraphics[width=10cm, height=7cm]{Figure7}
\\end{center}
\\end{document}
"""

rendered = render(marks_tmpl, TITLE = "Fitted parameters", time = timenow1, DF=df)

filename = string("C:\\Windows\\Temp\\","EstimationParameterReport.tex")
open(filename, "w") do file
  write(file, rendered)
end
run(`pdflatex $filename`)
DefaultApplication.open("EstimationParameterReport.pdf")
