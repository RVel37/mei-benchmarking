version 1.0

task scramble {
  input {
    File bam
    File bai
    File refGenomeBwaTar
    String dockerScramble
  }

  # dynamic instance
  Int disk_gb = ceil( 2* (size(bam, "GiB") + size(refGenomeBwaTar, "GiB")) ) + 2
  String mem = "64 GB"
  Int threads = 16
  Int cpu = (threads)/2

  command <<<

    # unpack reference genome
    mkdir -p ref
    tar -zxvf ~{refGenomeBwaTar} -C ref --no-same-owner
    referenceFasta=$(ls ref/*.fasta | head -n1)

    ### Step 1: create BLAST db
    makeblastdb -in "$referenceFasta" -dbtype nucl -parse_seqids -out "$referenceFasta"
    # creates basename.nhr, nin, nsq

    ### Step 2: Run clustering on the input BAM file
    cluster_identifier ~{bam} > "~{basename(bam, ".bam")}.clusters.txt"

    ### Step 3: Run SCRAMble.R using the clustered reads (full paths used)
    Rscript --vanilla /scramble/cluster_analysis/bin/SCRAMble.R \
      --out-name "$(pwd)/~{basename(bam, ".bam")}" \
      --cluster-file "$(pwd)/~{basename(bam, ".bam")}.clusters.txt" \
      --install-dir /scramble/cluster_analysis/bin \
      --mei-refs /scramble/cluster_analysis/resources/MEI_consensus_seqs.fa \
      --ref "$referenceFasta" \
      --poly-a-frac 0.5 --poly-a-dist 200 \
      --eval-meis

    ls 
       
    mv "~{basename(bam, ".bam")}_MEIs.txt" "~{basename(bam, ".bam")}.scramble.vcf"

  >>>

  output {
    File? clusters = "~{basename(bam, ".bam")}.clusters.txt"
    File? vcf = "~{basename(bam, ".bam")}.scramble.vcf"
  }

  runtime {
    docker: "${dockerScramble}"
    cpu: cpu
    gpu: false
    memory: "${mem}"
    disks: "local-disk ${disk_gb} SSD"
  }
}