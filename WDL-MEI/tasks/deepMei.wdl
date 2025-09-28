version 1.0

task deepMei {
  input {
    File bam
    File bai
    File refGenomeBwaTar
    String dockerDeepMei
  }

  # dynamic instance
  Int disk_gb = ceil( 2* (size(bam, "GiB") + size(refGenomeBwaTar, "GiB")) ) + 2
  String mem = "64 GB"
  Int threads = 16
  Int cpu = (threads)/2

  command <<<

    sample=~{basename(bam, ".bam")}

    # unpack reference genome
    mkdir -p ref
    tar -zxvf ~{refGenomeBwaTar} -C ref
    referenceFasta=$(ls ref/*.fasta | head -n1)

    # DEBUG: DEEPMEI REQUIRES A .FAI AND .DICT (NOT PROVIDED IN BWA REF)
    # create fai
    if [ ! -f "${referenceFasta}.fai" ]; then
        samtools faidx "$referenceFasta"
    fi

    # create dict 
    dict="${referenceFasta%.fasta}.dict" # (% = remove last part)
    if [ ! -f "$dict" ]; then
        awk '{print "@SQ\tSN:"$1"\tLN:"$2}' "${referenceFasta}.fai" > "$dict"
    fi

    # run deepMEI
    /root/DeepMEI/DeepMEI -i ~{bam} -r "$referenceFasta" -w $(pwd) -o "$sample"

    OUTDIR=$(pwd)/DeepMEI_output/${sample}
    VCF_FILE="${OUTDIR}/${sample}.vcf"

    if [ -f "\$VCF_FILE" ]; then
        mv "$VCF_FILE" "~{basename(bam, ".bam")}.deepmei.vcf"
    else
        echo "No VCF found"
    fi
  >>>

  output {
    File? vcf = "~{basename(bam, ".bam")}.deepMei.vcf"
  }

  runtime {
    docker: "${dockerDeepMei}"
        cpu: cpu
        gpu: false
        memory: "${mem}"
        disks: "local-disk ${disk_gb} SSD"
    }
}