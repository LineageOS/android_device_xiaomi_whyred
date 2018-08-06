#! /vendor/bin/sh

# Copyright (c) 2012-2013, 2016-2017, The Linux Foundation. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of The Linux Foundation nor
#       the names of its contributors may be used to endorse or promote
#       products derived from this software without specific prior written
#       permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NON-INFRINGEMENT ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

target=`getprop ro.board.platform`

function configure_zram_parameters() {
    MemTotalStr=`cat /proc/meminfo | grep MemTotal`
    MemTotal=${MemTotalStr:16:8}

    low_ram=`getprop ro.config.low_ram`

    # Zram disk - 75% for Go devices.
    # For 512MB Go device, size = 384MB
    # For 1GB Go device, size = 768MB
    # Others - 512MB size
    # And enable lz4 zram compression for Go devices
    zram_enable=`getprop ro.vendor.qti.config.zram`
    if [ "$zram_enable" == "true" ]; then
        if [ $MemTotal -le 524288 ] && [ "$low_ram" == "true" ]; then
            echo lz4 > /sys/block/zram0/comp_algorithm
            echo 402653184 > /sys/block/zram0/disksize
        elif [ $MemTotal -le 1048576 ] && [ "$low_ram" == "true" ]; then
            echo lz4 > /sys/block/zram0/comp_algorithm
            echo 805306368 > /sys/block/zram0/disksize
        else
            echo 536870912 > /sys/block/zram0/disksize
        fi
        mkswap /dev/block/zram0
        swapon /dev/block/zram0 -p 32758
    fi
}

function configure_memory_parameters() {
    # Set Memory paremeters.
    #
    # Set per_process_reclaim tuning parameters
    # 2GB 64-bit will have aggressive settings when compared to 1GB 32-bit
    # 1GB and less will use vmpressure range 50-70, 2GB will use 10-70
    # 1GB and less will use 512 pages swap size, 2GB will use 1024
    #
    # Set Low memory killer minfree parameters
    # 32 bit all memory configurations will use 15K series
    # 64 bit up to 2GB with use 14K, and above 2GB will use 18K
    #
    # Set ALMK parameters (usually above the highest minfree values)
    # 32 bit will have 53K & 64 bit will have 81K
    #

ProductName=`getprop ro.product.name`
low_ram=`getprop ro.config.low_ram`

if [ "$ProductName" == "msm8996" ]; then
      # Enable Adaptive LMK
      echo 1 > /sys/module/lowmemorykiller/parameters/enable_adaptive_lmk
      echo 81250 > /sys/module/lowmemorykiller/parameters/vmpressure_file_min

      configure_zram_parameters
else
    arch_type=`uname -m`
    MemTotalStr=`cat /proc/meminfo | grep MemTotal`
    MemTotal=${MemTotalStr:16:8}

    # Read adj series and set adj threshold for PPR and ALMK.
    # This is required since adj values change from framework to framework.
    adj_series=`cat /sys/module/lowmemorykiller/parameters/adj`
    adj_1="${adj_series#*,}"
    set_almk_ppr_adj="${adj_1%%,*}"

    # PPR and ALMK should not act on HOME adj and below.
    # Normalized ADJ for HOME is 6. Hence multiply by 6
    # ADJ score represented as INT in LMK params, actual score can be in decimal
    # Hence add 6 considering a worst case of 0.9 conversion to INT (0.9*6).
    # For uLMK + Memcg, this will be set as 6 since adj is zero.
    set_almk_ppr_adj=$(((set_almk_ppr_adj * 6) + 6))
    echo $set_almk_ppr_adj > /sys/module/lowmemorykiller/parameters/adj_max_shift
    echo $set_almk_ppr_adj > /sys/module/process_reclaim/parameters/min_score_adj

    #Set other memory parameters
    echo 0 > /sys/module/process_reclaim/parameters/enable_process_reclaim
    echo 70 > /sys/module/process_reclaim/parameters/pressure_max
    echo 30 > /sys/module/process_reclaim/parameters/swap_opt_eff
    echo 1 > /sys/module/lowmemorykiller/parameters/enable_adaptive_lmk
    if [ "$arch_type" == "aarch64" ] && [ $MemTotal -gt 2097152 ]; then
        echo 10 > /sys/module/process_reclaim/parameters/pressure_min
        echo 1024 > /sys/module/process_reclaim/parameters/per_swap_size
        echo "18432,23040,27648,32256,55296,80640" > /sys/module/lowmemorykiller/parameters/minfree
        echo 81250 > /sys/module/lowmemorykiller/parameters/vmpressure_file_min
    elif [ "$arch_type" == "aarch64" ] && [ $MemTotal -gt 1048576 ]; then
        echo 10 > /sys/module/process_reclaim/parameters/pressure_min
        echo 1024 > /sys/module/process_reclaim/parameters/per_swap_size
        echo "14746,18432,22118,25805,40000,55000" > /sys/module/lowmemorykiller/parameters/minfree
        echo 81250 > /sys/module/lowmemorykiller/parameters/vmpressure_file_min
    elif [ "$arch_type" == "aarch64" ]; then
        echo 50 > /sys/module/process_reclaim/parameters/pressure_min
        echo 512 > /sys/module/process_reclaim/parameters/per_swap_size
        echo "14746,18432,22118,25805,40000,55000" > /sys/module/lowmemorykiller/parameters/minfree
        echo 81250 > /sys/module/lowmemorykiller/parameters/vmpressure_file_min
    else
        if [ $MemTotal -le 1048576 ] && [ "$low_ram" == "true" ]; then
            # Disable KLMK, ALMK & PPR for Go devices
            echo 0 > /sys/module/lowmemorykiller/parameters/enable_lmk
            echo 0 > /sys/module/lowmemorykiller/parameters/enable_adaptive_lmk
            echo 0 > /sys/module/process_reclaim/parameters/enable_process_reclaim
        else
            echo 50 > /sys/module/process_reclaim/parameters/pressure_min
            echo 512 > /sys/module/process_reclaim/parameters/per_swap_size
            echo "15360,19200,23040,26880,34415,43737" > /sys/module/lowmemorykiller/parameters/minfree
            echo 53059 > /sys/module/lowmemorykiller/parameters/vmpressure_file_min
        fi
    fi

    configure_zram_parameters

    SWAP_ENABLE_THRESHOLD=1048576
    swap_enable=`getprop ro.vendor.qti.config.swap`

    if [ -f /sys/devices/soc0/soc_id ]; then
        soc_id=`cat /sys/devices/soc0/soc_id`
    else
        soc_id=`cat /sys/devices/system/soc/soc0/id`
    fi

    # Enable swap initially only for 1 GB targets
    if [ "$MemTotal" -le "$SWAP_ENABLE_THRESHOLD" ] && [ "$swap_enable" == "true" ]; then
        # Static swiftness
        echo 1 > /proc/sys/vm/swap_ratio_enable
        echo 70 > /proc/sys/vm/swap_ratio

        # Swap disk - 200MB size
        if [ ! -f /data/system/swap/swapfile ]; then
            dd if=/dev/zero of=/data/system/swap/swapfile bs=1m count=200
        fi
        mkswap /data/system/swap/swapfile
        swapon /data/system/swap/swapfile -p 32758
    fi
fi
}

function enable_memory_features()
{
    MemTotalStr=`cat /proc/meminfo | grep MemTotal`
    MemTotal=${MemTotalStr:16:8}

    if [ $MemTotal -le 2097152 ]; then
        #Enable B service adj transition for 2GB or less memory
        setprop ro.vendor.qti.sys.fw.bservice_enable true
        setprop ro.vendor.qti.sys.fw.bservice_limit 5
        setprop ro.vendor.qti.sys.fw.bservice_age 5000

        #Enable Delay Service Restart
        setprop ro.vendor.qti.am.reschedule_service true
    fi
}

function start_hbtp()
{
        # Start the Host based Touch processing but not in the power off mode.
        bootmode=`getprop ro.bootmode`
        if [ "charger" != $bootmode ]; then
                start hbtp
        fi
}

case "$target" in
    "sdm660")

        # Set the default IRQ affinity to the primary cluster. When a
        # CPU is isolated/hotplugged, the IRQ affinity is adjusted
        # to one of the CPU from the default IRQ affinity mask.
        echo f > /proc/irq/default_smp_affinity

        if [ -f /sys/devices/soc0/soc_id ]; then
                soc_id=`cat /sys/devices/soc0/soc_id`
        else
                soc_id=`cat /sys/devices/system/soc/soc0/id`
        fi

        if [ -f /sys/devices/soc0/hw_platform ]; then
                hw_platform=`cat /sys/devices/soc0/hw_platform`
        else
                hw_platform=`cat /sys/devices/system/soc/soc0/hw_platform`
        fi

        panel=`cat /sys/class/graphics/fb0/modes`
        if [ "${panel:5:1}" == "x" ]; then
            panel=${panel:2:3}
        else
            panel=${panel:2:4}
        fi

        if [ $panel -gt 1080 ]; then
            echo 2 > /proc/sys/kernel/sched_window_stats_policy
            echo 5 > /proc/sys/kernel/sched_ravg_hist_size
        else
            echo 3 > /proc/sys/kernel/sched_window_stats_policy
            echo 3 > /proc/sys/kernel/sched_ravg_hist_size
        fi
        #Apply settings for sdm660, sdm636,sda636
        case "$soc_id" in
                "317" | "324" | "325" | "326" | "345" | "346" )

            echo 2 > /sys/devices/system/cpu/cpu4/core_ctl/min_cpus
            echo 60 > /sys/devices/system/cpu/cpu4/core_ctl/busy_up_thres
            echo 30 > /sys/devices/system/cpu/cpu4/core_ctl/busy_down_thres
            echo 100 > /sys/devices/system/cpu/cpu4/core_ctl/offline_delay_ms
            echo 1 > /sys/devices/system/cpu/cpu4/core_ctl/is_big_cluster
            echo 4 > /sys/devices/system/cpu/cpu4/core_ctl/task_thres

            # Setting b.L scheduler parameters
            echo 96 > /proc/sys/kernel/sched_upmigrate
            echo 90 > /proc/sys/kernel/sched_downmigrate
            echo 140 > /proc/sys/kernel/sched_group_upmigrate
            echo 120 > /proc/sys/kernel/sched_group_downmigrate
            echo 0 > /proc/sys/kernel/sched_select_prev_cpu_us
            echo 400000 > /proc/sys/kernel/sched_freq_inc_notify
            echo 400000 > /proc/sys/kernel/sched_freq_dec_notify
            echo 5 > /proc/sys/kernel/sched_spill_nr_run
            echo 1 > /proc/sys/kernel/sched_restrict_cluster_spill
            echo 100000 > /proc/sys/kernel/sched_short_burst_ns
            echo 1 > /proc/sys/kernel/sched_prefer_sync_wakee_to_waker

            # cpuset settings
            echo 0-7 > /dev/cpuset/top-app/cpus
            echo 4-7 > /dev/cpuset/foreground/boost/cpus
            echo 0-2,4-7 > /dev/cpuset/foreground/cpus
            echo 0-1 > /dev/cpuset/background/cpus
            echo 0-2 > /dev/cpuset/system-background/cpus

            # disable thermal bcl hotplug to switch governor
            echo 0 > /sys/module/msm_thermal/core_control/enabled

            # online CPU0
            echo 1 > /sys/devices/system/cpu/cpu0/online
            # configure governor settings for little cluster
            echo "interactive" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
            echo 1 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/use_sched_load
            echo 1 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/use_migration_notif
            echo "19000 1401600:39000" > /sys/devices/system/cpu/cpu0/cpufreq/interactive/above_hispeed_delay
            echo 90 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/go_hispeed_load
            echo 20000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_rate
            echo 1401600 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/hispeed_freq
            echo 0 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/io_is_busy
            echo "85 1747200:95" > /sys/devices/system/cpu/cpu0/cpufreq/interactive/target_loads
            echo 39000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/min_sample_time
            echo 0 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/max_freq_hysteresis
            echo 633600 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
            echo 1 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/ignore_hispeed_on_notif
            echo 1 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/fast_ramp_down
            # online CPU4
            echo 1 > /sys/devices/system/cpu/cpu4/online
            # configure governor settings for big cluster
            echo "interactive" > /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
            echo 1 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/use_sched_load
            echo 1 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/use_migration_notif
            echo "19000 1401600:39000" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/above_hispeed_delay
            echo 90 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/go_hispeed_load
            echo 20000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/timer_rate
            echo 1401600 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/hispeed_freq
            echo 0 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/io_is_busy
            echo "85 1401600:90 2150400:95" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/target_loads
            echo 39000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/min_sample_time
            echo 59000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/max_freq_hysteresis
            echo 1113600 > /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq
            echo 1 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/ignore_hispeed_on_notif
            echo 1 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/fast_ramp_down

            # bring all cores online
            echo 1 > /sys/devices/system/cpu/cpu0/online
            echo 1 > /sys/devices/system/cpu/cpu1/online
            echo 1 > /sys/devices/system/cpu/cpu2/online
            echo 1 > /sys/devices/system/cpu/cpu3/online
            echo 1 > /sys/devices/system/cpu/cpu4/online
            echo 1 > /sys/devices/system/cpu/cpu5/online
            echo 1 > /sys/devices/system/cpu/cpu6/online
            echo 1 > /sys/devices/system/cpu/cpu7/online

            # configure LPM
            echo N > /sys/module/lpm_levels/system/pwr/cpu0/ret/idle_enabled
            echo N > /sys/module/lpm_levels/system/pwr/cpu1/ret/idle_enabled
            echo N > /sys/module/lpm_levels/system/pwr/cpu2/ret/idle_enabled
            echo N > /sys/module/lpm_levels/system/pwr/cpu3/ret/idle_enabled
            echo N > /sys/module/lpm_levels/system/perf/cpu4/ret/idle_enabled
            echo N > /sys/module/lpm_levels/system/perf/cpu5/ret/idle_enabled
            echo N > /sys/module/lpm_levels/system/perf/cpu6/ret/idle_enabled
            echo N > /sys/module/lpm_levels/system/perf/cpu7/ret/idle_enabled
            echo N > /sys/module/lpm_levels/system/pwr/pwr-l2-dynret/idle_enabled
            echo N > /sys/module/lpm_levels/system/perf/perf-l2-dynret/idle_enabled
            echo N > /sys/module/lpm_levels/system/pwr/pwr-l2-ret/idle_enabled
            echo N > /sys/module/lpm_levels/system/perf/perf-l2-ret/idle_enabled
            # enable LPM
            echo 0 > /sys/module/lpm_levels/parameters/sleep_disabled

            # re-enable thermal and BCL hotplug
            echo 1 > /sys/module/msm_thermal/core_control/enabled

            #Add-begin-HMI_L8866_A01-794,lijiang@longcheer.com,2018-01-20
            #Enable input boost configuration
            echo "0:1401600" > /sys/module/cpu_boost/parameters/input_boost_freq
            echo 40 > /sys/module/cpu_boost/parameters/input_boost_ms
            #Add-end-HMI_L8866_A01-794
            # Set Memory parameters
            configure_memory_parameters

            # Enable bus-dcvs
            for cpubw in /sys/class/devfreq/*qcom,cpubw*
            do
                echo "bw_hwmon" > $cpubw/governor
                echo 50 > $cpubw/polling_interval
                echo 762 > $cpubw/min_freq
                echo "1525 3143 5859 7759 9887 10327 11863 13763" > $cpubw/bw_hwmon/mbps_zones
                echo 4 > $cpubw/bw_hwmon/sample_ms
                echo 85 > $cpubw/bw_hwmon/io_percent
                echo 100 > $cpubw/bw_hwmon/decay_rate
                echo 50 > $cpubw/bw_hwmon/bw_step
                echo 20 > $cpubw/bw_hwmon/hist_memory
                echo 0 > $cpubw/bw_hwmon/hyst_length
                echo 80 > $cpubw/bw_hwmon/down_thres
                echo 0 > $cpubw/bw_hwmon/low_power_ceil_mbps
                echo 34 > $cpubw/bw_hwmon/low_power_io_percent
                echo 20 > $cpubw/bw_hwmon/low_power_delay
                echo 0 > $cpubw/bw_hwmon/guard_band_mbps
                echo 250 > $cpubw/bw_hwmon/up_scale
                echo 1600 > $cpubw/bw_hwmon/idle_mbps
            done

            for memlat in /sys/class/devfreq/*qcom,memlat-cpu*
            do
                echo "mem_latency" > $memlat/governor
                echo 10 > $memlat/polling_interval
                echo 400 > $memlat/mem_latency/ratio_ceil
            done
            echo "cpufreq" > /sys/class/devfreq/soc:qcom,mincpubw/governor


            # Start Host based Touch processing
            #    case "$hw_platform" in
            #            "MTP" | "Surf" | "RCM" | "QRD" )
            #            start_hbtp
            #            ;;
            #    esac
            ;;
        esac
        #Apply settings for sdm630
        case "$soc_id" in
            "318" | "327" )

            # Start Host based Touch processing
            #case "$hw_platform" in
            #    "MTP" | "Surf" | "RCM" | "QRD" )
            #    start_hbtp
            #    ;;
            #esac

            # Setting b.L scheduler parameters
            echo 85 > /proc/sys/kernel/sched_upmigrate
            echo 85 > /proc/sys/kernel/sched_downmigrate
            echo 900 > /proc/sys/kernel/sched_group_upmigrate
            echo 900 > /proc/sys/kernel/sched_group_downmigrate
            echo 0 > /proc/sys/kernel/sched_select_prev_cpu_us
            echo 400000 > /proc/sys/kernel/sched_freq_inc_notify
            echo 400000 > /proc/sys/kernel/sched_freq_dec_notify
            echo 3 > /proc/sys/kernel/sched_spill_nr_run

            #init task load, restrict wakeups to preferred cluster
            echo 15 > /proc/sys/kernel/sched_init_task_load
            echo 1 > /proc/sys/kernel/sched_restrict_cluster_spill
            echo 50000 > /proc/sys/kernel/sched_short_burst_ns

            # cpuset settings
            echo 0-3 > /dev/cpuset/background/cpus
            echo 0-3 > /dev/cpuset/system-background/cpus

            # disable thermal bcl hotplug to switch governor
            echo 0 > /sys/module/msm_thermal/core_control/enabled
            for mode in /sys/devices/soc.0/qcom,bcl.*/mode
            do
                echo -n disable > $mode
            done
            for hotplug_mask in /sys/devices/soc.0/qcom,bcl.*/hotplug_mask
            do
                bcl_hotplug_mask=`cat $hotplug_mask`
                echo 0 > $hotplug_mask
            done
            for hotplug_soc_mask in /sys/devices/soc.0/qcom,bcl.*/hotplug_soc_mask
            do
                bcl_soc_hotplug_mask=`cat $hotplug_soc_mask`
                echo 0 > $hotplug_soc_mask
            done
            for mode in /sys/devices/soc.0/qcom,bcl.*/mode
            do
                echo -n enable > $mode
            done

            # online CPU0
            echo 1 > /sys/devices/system/cpu/cpu0/online
            # configure governor settings for Big cluster(CPU0 to CPU3)
            echo "interactive" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
            echo 1 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/use_sched_load
            echo 1 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/use_migration_notif
            echo "19000 1344000:39000" > /sys/devices/system/cpu/cpu0/cpufreq/interactive/above_hispeed_delay
            echo 85 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/go_hispeed_load
            echo 20000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_rate
            echo 1344000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/hispeed_freq
            echo 0 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/io_is_busy
            echo "85 1344000:80" > /sys/devices/system/cpu/cpu0/cpufreq/interactive/target_loads
            echo 39000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/min_sample_time
            echo 0 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/max_freq_hysteresis
            echo 787200 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
            echo 0 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/ignore_hispeed_on_notif

            # online CPU4
            echo 1 > /sys/devices/system/cpu/cpu4/online
            # configure governor settings for Little cluster(CPU4 to CPU7)
            echo "interactive" > /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
            echo 1 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/use_sched_load
            echo 1 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/use_migration_notif
            echo "19000 1094400:39000" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/above_hispeed_delay
            echo 85 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/go_hispeed_load
            echo 20000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/timer_rate
            echo 1094400 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/hispeed_freq
            echo 0 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/io_is_busy
            echo "85 1094400:80" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/target_loads
            echo 39000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/min_sample_time
            echo 0 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/max_freq_hysteresis
            echo 614400 > /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq
            echo 0 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/ignore_hispeed_on_notif

            # bring all cores online
            echo 1 > /sys/devices/system/cpu/cpu0/online
            echo 1 > /sys/devices/system/cpu/cpu1/online
            echo 1 > /sys/devices/system/cpu/cpu2/online
            echo 1 > /sys/devices/system/cpu/cpu3/online
            echo 1 > /sys/devices/system/cpu/cpu4/online
            echo 1 > /sys/devices/system/cpu/cpu5/online
            echo 1 > /sys/devices/system/cpu/cpu6/online
            echo 1 > /sys/devices/system/cpu/cpu7/online

            # configure LPM
            echo N > /sys/module/lpm_levels/system/perf/cpu0/ret/idle_enabled
            echo N > /sys/module/lpm_levels/system/perf/cpu1/ret/idle_enabled
            echo N > /sys/module/lpm_levels/system/perf/cpu2/ret/idle_enabled
            echo N > /sys/module/lpm_levels/system/perf/cpu3/ret/idle_enabled
            echo N > /sys/module/lpm_levels/system/pwr/cpu4/ret/idle_enabled
            echo N > /sys/module/lpm_levels/system/pwr/cpu5/ret/idle_enabled
            echo N > /sys/module/lpm_levels/system/pwr/cpu6/ret/idle_enabled
            echo N > /sys/module/lpm_levels/system/pwr/cpu7/ret/idle_enabled
            echo N > /sys/module/lpm_levels/system/pwr/pwr-l2-dynret/idle_enabled
            echo N > /sys/module/lpm_levels/system/perf/perf-l2-dynret/idle_enabled
            # enable LPM
            echo 0 > /sys/module/lpm_levels/parameters/sleep_disabled

            # re-enable thermal and BCL hotplug
            echo 1 > /sys/module/msm_thermal/core_control/enabled
            for mode in /sys/devices/soc.0/qcom,bcl.*/mode
            do
                echo -n disable > $mode
            done
            for hotplug_mask in /sys/devices/soc.0/qcom,bcl.*/hotplug_mask
            do
                echo $bcl_hotplug_mask > $hotplug_mask
            done
            for hotplug_soc_mask in /sys/devices/soc.0/qcom,bcl.*/hotplug_soc_mask
            do
                echo $bcl_soc_hotplug_mask > $hotplug_soc_mask
            done
            for mode in /sys/devices/soc.0/qcom,bcl.*/mode
            do
                echo -n enable > $mode
            done

            # Set Memory parameters
            configure_memory_parameters

            # Enable bus-dcvs
            for cpubw in /sys/class/devfreq/*qcom,cpubw*
            do
                echo "bw_hwmon" > $cpubw/governor
                echo 50 > $cpubw/polling_interval
                echo 762 > $cpubw/min_freq
                echo "1525 3143 4173 5195 5859 7759 9887 10327" > $cpubw/bw_hwmon/mbps_zones
                echo 4  > $cpubw/bw_hwmon/sample_ms
                echo 85 > $cpubw/bw_hwmon/io_percent
                echo 20 > $cpubw/bw_hwmon/hist_memory
                echo 0  > $cpubw/bw_hwmon/hyst_length
                echo 100 > $cpubw/bw_hwmon/decay_rate
                echo 50 > $cpubw/bw_hwmon/bw_step
                echo 80 > $cpubw/bw_hwmon/down_thres
                echo 0  > $cpubw/bw_hwmon/low_power_ceil_mbps
                echo 50 > $cpubw/bw_hwmon/low_power_io_percent
                echo 20 > $cpubw/bw_hwmon/low_power_delay
                echo 0  > $cpubw/bw_hwmon/guard_band_mbps
                echo 250 > $cpubw/bw_hwmon/up_scale
                echo 1600 > $cpubw/bw_hwmon/idle_mbps
            done

            for memlat in /sys/class/devfreq/*qcom,memlat-cpu*
            do
                echo "mem_latency" > $memlat/governor
                echo 10 > $memlat/polling_interval
                echo 400 > $memlat/mem_latency/ratio_ceil
            done

            echo "cpufreq" > /sys/class/devfreq/soc:qcom,mincpubw/governor
            ;;
        esac
    ;;
esac

chown -h system /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate
chown -h system /sys/devices/system/cpu/cpufreq/ondemand/sampling_down_factor
chown -h system /sys/devices/system/cpu/cpufreq/ondemand/io_is_busy

# Post-setup services
case "$target" in
    "msm8994" | "msm8992" | "msm8996" | "msm8998" | "sdm660" | "apq8098_latv" | "sdm845")
        setprop sys.post_boot.parsed 1
    ;;

# Let kernel know our image version/variant/crm_version
if [ -f /sys/devices/soc0/select_image ]; then
    image_version="10:"
    image_version+=`getprop ro.build.id`
    image_version+=":"
    image_version+=`getprop ro.build.version.incremental`
    image_variant=`getprop ro.product.name`
    image_variant+="-"
    image_variant+=`getprop ro.build.type`
    oem_version=`getprop ro.build.version.codename`
    echo 10 > /sys/devices/soc0/select_image
    echo $image_version > /sys/devices/soc0/image_version
    echo $image_variant > /sys/devices/soc0/image_variant
    echo $oem_version > /sys/devices/soc0/image_crm_version
fi

# Change console log level as per console config property
console_config=`getprop persist.console.silent.config`
case "$console_config" in
    "1")
        echo "Enable console config to $console_config"
        echo 0 > /proc/sys/kernel/printk
        ;;
    *)
        echo "Enable console config to $console_config"
        ;;
esac

# Parse misc partition path and set property
misc_link=$(ls -l /dev/block/bootdevice/by-name/misc)
real_path=${misc_link##*>}
setprop persist.vendor.mmi.misc_dev_path $real_path

