# Piechart Module

The Piechart Module creates HTML that with some CSS transforms creates a pie chart.

The templates for plwiki and enwiki are different, but CSS is mostly the same. The enwiki CSS just has this additional `{{pp-template}}` marker.

## Links

| Type        | enwiki                                                                 | plwiki                                                                  |
|-------------|------------------------------------------------------------------------|-------------------------------------------------------------------------|
| CSS         | [Template:Pie chart/styles.css](https://en.wikipedia.org/wiki/Template:Pie_chart/styles.css) | [Template:Piechart/style.css](https://pl.wikipedia.org/wiki/Template:Piechart/style.css) |
| Template    | [Template:Pie chart](https://en.wikipedia.org/wiki/Template:Pie_chart) | [Template:Piechart](https://pl.wikipedia.org/wiki/Template:Piechart)   |
| Module      | [Module:Piechart](https://en.wikipedia.org/wiki/Module:Piechart)       | [Module:Piechart](https://pl.wikipedia.org/wiki/Module:Piechart)       |
| Test cases  | [Template:Pie chart/testcases](https://en.wikipedia.org/wiki/Template:Pie_chart/testcases) | [Module:Piechart/test](https://pl.wikipedia.org/wiki/Module:Piechart/test) |

## Cloning

This repository includes a Lua mw toolkit loaded as a submodule.

### Clone with submodules

Make sure to clone with submodules:

```bash
git clone --recurse-submodules https://github.com/Eccenux/wiki-lua-piechart.git
```

### Load submodules after clone

If you've already cloned without `--recurse-submodules`, run:

```bash
git submodule update --init --recursive
```
