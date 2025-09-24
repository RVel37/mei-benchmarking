version 1.0

task mobster {
    input {
        File bam
        File bai
        File mobsterProperties
        String dockerMobster
    }

    # dynamic instance
    Int disk_gb = ceil( 2* (size(bam, "GiB"))) + 2
    String mem = "32 GB"
    Int threads = 8
    Int cpu = (threads)/2

    command <<<

        touch txt.exists
        # Mobster only ran correctly if inputs are in /mobster subdir
        # in interactive session. 

        cd /mobster
        mkdir -p data; cp ~{bam} ~{bai} .
        

        java -Xmx8G \
            -cp /mobster/target/MobileInsertions-0.2.4.1.jar \
            org.umcn.me.pairedend.Mobster \
            -properties ~{mobsterProperties} \
            -in ~{bam} \
            -sn ~{basename(bam, ".bam")} \
            -out "data/~{basename(bam, '.bam')}"

        # move text output        
        if compgen -G "data/~{basename(bam, '.bam')}*.txt" > /dev/null; then
            mv data/~{basename(bam, '.bam')}*.txt /~{basename(bam, '.bam')}.mobster.txt
            echo true > /txt.exists
        else
            echo false > /txt.exists
        fi
        >>>

    output {
        File? txt = "~{basename(bam, '.bam')}.mobster.txt"
        Boolean txt_exists = read_boolean("txt.exists")
    }
    
    runtime {
        docker: "${dockerMobster}"
        cpu: cpu
        gpu: false
        memory: "${mem}"
        disks: "local-disk ${disk_gb} SSD"
    }
}



task mobVcf {
    input {
        File? txt
        String dockerMobVcf
    }

    # dynamic instance
    Int disk_gb = 4
    String mem = "8 GB"
    Int threads = 8
    Int cpu = (threads)/2

    command <<<
    java -jar /mobstertovcf/MobsterVCF-0.0.1-SNAPSHOT.jar \
    -file ~{txt} \
    -out ~{basename(txt, ".txt")}.mobster.vcf
    >>>

    output {
        File? vcf = "~{basename(txt, ".txt")}.mobster.vcf"
    }

    runtime {
    docker: "${dockerMobVcf}"
    cpu: cpu
    gpu: false
    memory: "${mem}"
    disks: "local-disk ${disk_gb} SSD"
    }  
}