#!/usr/bin/env nextflow

params.what = "words"

process countThings {
    cpus 1
    memory "100MB"
    time "1m"

    input:
    path txt_file

    output:
    path "*.counts"

    """
    wc -${params.what[0]} ${txt_file} > ${txt_file}.counts
    """
}

process average {
    cpus 1
    memory "100MB"
    time "1m"
    publishDir "${launchDir}"

    input:
    path counts

    output:
    path "average.txt"

    """
    #!/usr/bin/env python3

    from statistics import mean, stdev

    cns = "${counts}".split()
    cns = [int(open(c).read().split()[0]) for c in cns]
    m = mean(cns)
    s = stdev(cns)

    with open("average.txt", "w") as out:
        out.write(f"Number of texts: {len(cns)}\\n")
        out.write(f"Average number of ${params.what}: {m} ± {s:.1f}\\n")
    """
}

workflow {
    texts = Channel.fromPath("${launchDir}/shakespeare/*.txt")

    countThings(texts)
    average(countThings.out.collect())
}