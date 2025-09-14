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
  String mem = "32 GB"
  Int threads = 8
  Int cpu = (threads)/2

  command <<<

    # unpack reference genome
    mkdir -p refGenome
    tar -zxvf ~{refGenomeBwaTar} -C refGenome
    referenceFasta=$(ls refGenome/*.fa | head -n1)

    ### Step 1: Run clustering on the input BAM file
    cluster_identifier ~{bam} > "~{basename(bam, ".bam")}.clusters.txt"

    ### Step 2: Run SCRAMble.R using the clustered reads (full paths used)
    Rscript --vanilla /scramble/cluster_analysis/bin/SCRAMble.R \
      --out-name "$(pwd)/~{basename(bam, ".bam")}" \
      --cluster-file "$(pwd)/~{basename(bam, ".bam")}.clusters.txt" \
      --install-dir /scramble/cluster_analysis/bin \
      --mei-refs /scramble/cluster_analysis/resources/MEI_consensus_seqs.fa \
      --ref "$referenceFasta" \
      --eval-meis \
      --eval-dels

    mv "~{basename(bam, ".bam")}.vcf" "~{basename(bam, ".bam")}.scramble.vcf"
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