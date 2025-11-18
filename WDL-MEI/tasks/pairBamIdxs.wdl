version 1.0

task pairBamIdxs {
    input {
    File bam
    Array[File] bais 
    String dockerSamtools
    }

  Int disk_gb = ceil( 2* (size(bam, "GiB")) ) + 2
  String mem = "8 GB"
  Int threads = 4
  Int cpu = (threads)/2

    command <<<

        bam_basename=$(basename ~{bam} .bam)
        bai_file="${bam_basename}.bam.bai"

        # look for a matching BAI in the provided array
        matching_bai=""
        for bai in ~{sep=' ' bais}; do
            bai_basename=$(basename "$bai" .bai)
            if [[ "$bai_basename" == "$bam_basename" ]]; then
                matching_bai=$bai
                break
            fi
        done

        # index bam if necessary
        if [[ -n "$matching_bai" ]]; then
            cp "$matching_bai" "$bai_file"
        else
            samtools index -b ~{bam} -o "$bai_file"
        fi
    >>>

    output {
        File paired_bam = "~{bam}"
        File bai = "~{basename(bam)}.bai"
    }

    runtime {
        docker: "${dockerSamtools}"
        cpu: cpu
        gpu: false
        memory: "${mem}"
        disks: "local-disk ${disk_gb} SSD"
    }
}