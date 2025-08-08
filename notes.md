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
- [ ] Check adding labels in value mode after changes... Module was adding percentages to labels unexpectedly

## Long names

Add support for long variables:
- [ ] $label ($L)
- [ ] $auto ($v)
- [ ] $formattedRawData ($d)
- [ ] $percentNumber ($p)

## Cleanup

- [ ] Report unknown $x in template during preview.
- [ ] Report when $x is not supported in current mode (autoscale off).
- [ ] Docs:
	- [ ] Add table with long and short variable names and an example renders of large and small numbers.
	- [ ] Use longer versions in new examples of `labelformat` option.