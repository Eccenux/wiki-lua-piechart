## Github

- [x] Git export
	- [x] tpl & css from pl&en (separate by project; [wiki2git](https://www.npmjs.com/package/wiki-to-git))
	- [x] lua module (common; wiki2git)
- Git enhance
	- [x] lua test framework
	- [x] [wikiploy-dev](https://www.npmjs.com/package/wikiploy) to en
	- [x] [wikiploy](https://www.npmjs.com/package/wikiploy) to pl
	- [x] [wikiploy](https://www.npmjs.com/package/wikiploy) to en

## New option labelformat

- [x] global label formatting template support:
	- [x] add new option to meta -> labelformat
	- [x] value of default tpl: "$L: $v"
	- [x] can I / should I sanitize it? -> No, probably not needed.
	- [x] support for $v, $d, $p
	- [x] testing
- [x] Check testcases on sandbox. -> identical.
- [x] Add testcases for labelformat.
- [x] Release: pl, en.
- [x] Fix adding variables to labels in enum-values mode (non-JSON)... [Module was adding percentages to labels unexpectedly](https://en.wikipedia.org/wiki/Template_talk:Pie_chart#c-Novarupta-20250601085500-Template_adds_incorrect_percentages_to_labels)

## Long names

Add support for long variables:
- [x] $label ($L)
- [x] $auto ($v)
- [x] $value ($d)
- [x] $percent ($p)

## Cleanup

- [x] Report unknown $var in template during preview.
- [x] Docs:
	- [x] TemplateData en.
	- [x] TemplateData pl.
	- [x] Testcases with long names.
	- [x] Add table with long and short variable names and an example renders of large and small numbers.
	- [x] Use longer versions in new examples of `labelformat` option.
