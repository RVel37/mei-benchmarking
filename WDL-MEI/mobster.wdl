version 1.0

task mobster {
    input {
        File bam
        File bai
        File refGenomeBwaTar
        String dockerMobster
    }

    # dynamic instance
    Int disk_gb = ceil( 2* (size(bam, "GiB") + size(refGenomeBwaTar, "GiB")) ) + 2
    String mem = "32 GB"
    Int threads = 8
    Int cpu = (threads)/2

    command <<<

        # Mobster only ran correctly if inputs are in /mobster subdir
        # in interactive session. reference copied variables below if
        # it doesn't work normally.

        cd /mobster; mkdir -p data; cd data
        cp ~{bam} ~{bai} .
        # unpack reference genome
        tar -zxvf ~{refGenomeBwaTar} -C ref --no-same-owner
        referenceFasta=$(ls ref/*.fasta | head -n1)
        
        # change 'Mobster.properties' reference file from hg19 to 38
        sed -i 's|repmask/hg19_alul1svaerv.rpmsk|repmask/alu_l1_herv_sva_other_grch38_accession_ucsc.rpmsk|' /mobster/lib/Mobster.properties

        java -Xmx8G \
            -cp ../target/MobileInsertions-0.2.4.1.jar \
            org.umcn.me.pairedend.Mobster \
            -properties ../lib/Mobster.properties \
            -in ~{bam} \
            -sn ~{basename(bam, ".bam")} \
            -out ~{basename(bam, ".bam")}

        mv /mobster/data/~{basename(bam, ".bam")*.txt ../../~{basename(bam, ".bam")}.mobster.txt # move to root and rename

        >>>

        output {
            File? txt = "~{basename(bam, ".bam")}.mobster.txt"
        }

        runtime {
            docker: "${dockerScramble}"
            cpu: cpu
            gpu: false
            memory: "${mem}"
            disks: "local-disk ${disk_gb} SSD"
        }
    }
}