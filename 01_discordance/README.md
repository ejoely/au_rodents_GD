# 1. Gene tree discordance

Steps:
1. Infer the species tree and gene trees (IQ-TREE 2)
2. Collapse gene-tree nodes with SH-aLRT support < 80 (TreeCollapseCL4)
3. Compare the species tree with the collapsed gene trees (PhyParts)
4. Plot and summarise the PhyParts results

## 1.1 Species tree and gene trees

Species tree from the concatenated alignment `148Ftree.nex`, with *Rattus fuscipes* as outgroup:

```bash
iqtree2 -s 148Ftree.nex -B 1000 -m GTR+G \
  -o EC1_Rattus_fuscipes_GI02R01 -T 4
```

Gene trees from the alignment `148Fgenetree.nex` and the partition file `RatPartitions2.nex`:

```bash
iqtree2 -s 148Fgenetree.nex -S RatPartitions2.nex \
  -alrt 1000 -B 1000 -m GTR+G \
  -o EC1_Rattus_fuscipes_GI02R01 -T 8
```

The gene tree output files (`RatPartitions2.*`) were renamed to `148Fgenetree_output.*`.
The species tree output (`148Ftree.nex.treefile`) was renamed to `148Fsptree.nex.treefile`.

## 1.2 Collapse poorly supported nodes

Keep only the SH-aLRT values:

```bash
sed -E 's/\)([0-9.]+)\/[0-9.]+:/)\1:/g' 148Fgenetree_output.treefile > 148Fgenetree_stripped.treefile
```

Split the gene trees into one file per tree:

```bash
mkdir -p split_trees
awk '{filename = "split_trees/tree" NR ".nwk"; print > filename}' 148Fgenetree_stripped.treefile
```

Collapse nodes with support < 80 using [TreeCollapseCL4](http://emmahodcroft.com/TreeCollapseCL.html):

```bash
java -jar TreeCollapseCL4.jar -b 80 -t o -p -r EC1_Rattus_fuscipes_GI02R01 \
  -d split_trees/*.nwk -l
```

Recombine the collapsed trees:

```bash
cat 80coll_nwk/*.nwk > 148F_collapsed_all.treefile
```

## 1.3 PhyParts

Download [PhyParts](https://bitbucket.org/blackrim/phyparts) and build it following its README:

```bash
git clone https://bitbucket.org/blackrim/phyparts.git
```

Run inside the phyparts folder. `148test/` contains the species tree and `148test/148col/` contains `148F_collapsed_all.treefile`:

```bash
java -jar target/phyparts-0.0.1-SNAPSHOT-jar-with-dependencies.jar \
  -a 1 -v \
  -d 148test/148col/ \
  -m 148test/148Fsptree.nex.treefile \
  -o 148out/148F_phyparts
```

## 1.4 Results

Pie charts with [phypartspiecharts.py](https://github.com/mossmatters/MJPythonNotebooks) (1272 gene trees):

```bash
python phypartspiecharts.py 148Fsptree.nex.treefile 148out/148F_phyparts 1272
```

Proportion of discordant gene trees per node:

```bash
bash discordance_summary.sh <phyparts_prefix>
```
