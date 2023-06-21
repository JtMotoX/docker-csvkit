# docker-csvkit

This is a lightweight (~35mb compressed) Docker image that will convert files to/from xlsx, csv, sql, json, etc.. using [csvkit](https://csvkit.readthedocs.io/en/latest/#why-csvkit).

---

## Examples:

Get a list of all the command utilities:
```bash
docker run --rm -i jtmotox/csvkit
```

Convert the `sample.xlsx` file in `./directory/of/xlsx/files` to `sample.csv`:
```bash
docker run --rm -i -v "./directory/of/xlsx/files:/data" jtmotox/csvkit sh -c "in2csv sample.xlsx >sample.csv"
```

Output to stdout instead of saving to csv file:

```bash
docker run --rm -i -v "./directory/of/xlsx/files:/data" jtmotox/csvkit sh -c "in2csv sample.xlsx"
```

Parse xlsx files using [jq](https://stedolan.github.io/jq/):

```bash
docker run --rm -i -v "./directory/of/xlsx/files:/data" jtmotox/csvkit sh -c "in2csv sample.xlsx | csvjson | jq -r '.'"
```
