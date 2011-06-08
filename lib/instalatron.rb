require 'fileutils'
require 'yaml'
require 'virtualbox'

module Instalatron
  
  VERSION = '0.1.2'

  def self.destroy_vm(vm_name)
    `VBoxManage controlvm '#{vm_name}' poweroff > /dev/null 2>&1`
    # dumb
    sleep 1
    `VBoxManage unregistervm  '#{vm_name}' --delete > /dev/null 2>&1`
  end

  def self.create_vm(params = {})
    vm_name = params[:vm_name] || "instalatron_#{Time.now.to_f}"
    full_iso_file = params[:iso_file] 
    if full_iso_file.nil? or not File.exist?(full_iso_file)
      raise ArgumentError.new("Invalid :iso_file parameter.")
    end
    os_type = params[:os_type] || 'RedHat_64'
    vboxcmd = params[:vboxcmd] || 'VBoxManage'
    vm_memory = params[:vm_memory] || 512
    vm_cpus = params[:vm_cpus] || 1
    # listing os types
    # VirtualBox::Global.global.lib.virtualbox.guest_os_types.each do |os|
    #   puts os.id
    # end
    
    # make sure the VM does not exist
    vm=VirtualBox::VM.find(vm_name)
    
    if vm.nil?
      `#{vboxcmd} createvm --name '#{vm_name}' --ostype #{os_type} --register >/dev/null 2>&1`
      `#{vboxcmd} modifyvm #{vm_name} --ioapic on >/dev/null 2>&1`
      `#{vboxcmd} modifyvm #{vm_name} --pae on >/dev/null 2>&1`
    else
      exit 1
    end
    
    vm=VirtualBox::VM.find(vm_name)
    vm.memory_size= vm_memory
    vm.os_type_id = os_type
    vm.cpu_count  = vm_cpus
    vm.name = vm_name
    
    vm.boot_order[0]=:dvd
    vm.boot_order[1]=:hard_disk
    vm.boot_order[2]=:null
    vm.boot_order[3]=:null
    vm.validate
    vm.save
    
    # Create DISK
    place = `#{vboxcmd}  list  systemproperties|grep '^Default machine'|cut -d ':' -f 2|sed -e 's/^[ ]*//'`.strip.chomp 
    disk_file = "#{place}/#{vm_name}/#{vm_name}.vdi"
    
    `#{vboxcmd} createhd --filename '#{disk_file}' --size 8192 --format VDI >/dev/null 2>&1`
    
    # Add IDE/Sata Controllers
    `#{vboxcmd} storagectl '#{vm_name}' --name 'SATA Controller' --add sata --hostiocache off >/dev/null 2>&1`
    `#{vboxcmd} storagectl '#{vm_name}' --name 'IDE Controller' --add ide >/dev/null 2>&1`
    
    # Attach disk
    `#{vboxcmd} storageattach '#{vm_name}' --storagectl 'SATA Controller' --port 0 --device 0 --type hdd --medium '#{disk_file}' >/dev/null 2>&1`
    
    `#{vboxcmd} storageattach '#{vm_name}' --storagectl 'IDE Controller' --type dvddrive --port 1 --device 0 --medium '#{full_iso_file}' >/dev/null 2>&1`

    vm.start
  end

  def self.command_window(seq, vm_name, key_press_delay = 0)
    if seq.is_a? String
      seq = [seq]
    end
    seq.each do |str|
      keycodes = string_to_keycode str
      keycodes.split.each do |k|
        `VBoxManage controlvm #{vm_name} keyboardputscancode '#{k}' >/dev/null 2>&1`
      end
      #sleep key_press_delay
    end
  end

  def self.grab_screenshot(vm_name, dest_file = nil)
    if dest_file.nil?
      dest_file = vm_name + "_#{Time.now.to_f}.png"
    end
    `VBoxManage controlvm #{vm_name} screenshotpng #{dest_file} >/dev/null 2>&1`
  end

  def self.same_image?(ref_image, new_img, threshold = 1500)
    `file #{ref_image}` =~ /(\d+\sx\s\d+)/ 
    geom1 = $1
    `file #{new_img}` =~ /(\d+\sx\s\d+)/ 
    geom2 = $1

    # geometries are different
    return false if geom1 != geom2

    tmp_img = "/tmp/diff_#{Time.now.to_f}.png"
    metric = `compare -metric RMSE #{ref_image} #{new_img} #{tmp_img} 2>&1`.strip.chomp.split[0].to_i
    FileUtils.rm tmp_img if File.exist?(tmp_img)
    if metric < threshold
      return true
    end
    false
  end

  def self.detect_screen(vm_name)
    new_img = '/tmp/' + vm_name + '_new.png'
    old_img = '/tmp/' + vm_name + '_old.png'
    loop do
      grab_screenshot(vm_name, old_img)
      sleep 0.5
      grab_screenshot(vm_name, new_img)
      break if same_image?(old_img, new_img)
    end
    new_img
  end

  def self.string_to_keycode(thestring)
          k=Hash.new
          k['1'] = '02 82'
          k['2'] = '03 83'
          k['3'] = '04 84'
          k['4'] = '05 85'
          k['5'] = '06 86'
          k['6'] = '07 87'
          k['7'] = '08 88'
          k['8'] = '09 89'
          k['9'] = '0a 8a'
          k['0'] = '0b 8b'
          k['-'] = '0c 8c' 
          k['='] = '0d 8d'
          k['Tab'] = '0f 8f'; 
          k['q']  = '10 90' ;       k['w']  = '11 91' ;       k['e']  = '12 92';  
               k['r'] = '13 93'       ; k['t'] = '14 94'       ; k['y'] = '15 95';   
                  k['u']= '16 96'        ; k['i']='17 97';      k['o'] = '18 98'       ; k['p'] = '19 99' ; 
         
          k['Q']  = '2a 10 aa' ; k['W']  = '2a 11 aa' ; k['E']  = '2a 12 aa'; k['R'] = '2a 13 aa' ; k['T'] = '2a 14 aa' ; k['Y'] = '2a 15 aa'; k['U']= '2a 16 aa' ; k['I']='2a 17 aa'; k['O'] = '2a 18 aa' ; k['P'] = '2a 19 aa' ;

          k['a'] = '1e 9e'; k['s']  = '1f 9f' ; k['d']  = '20 a0' ; k['f']  = '21 a1'; k['g'] = '22 a2' ; k['h'] = '23 a3' ; k['j'] = '24 a4'; 
          k['k']= '25 a5' ; k['l']='26 a6';
          k['A'] = '2a 1e aa 9e'; k['S']  = '2a 1f aa 9f' ; k['D']  = '2a 20 aa a0' ; k['F']  = '2a 21 aa a1';
           k['G'] = '2a 22 aa a2' ; k['H'] = '2a 23 aa a3' ; k['J'] = '2a 24 aa a4'; k['K']= '2a 25 aa a5' ; k['L']='2a 26 aa a6'; 
          
          k[';'] = '27 a7' ;k['"']='2a 28 aa a8';k['\'']='28 a8';

          k['\\'] = '2b ab';   k['|'] = '2a 2b aa 8b';

          k['[']='1a 9a'; k[']']='1b 9b';
          k['<']='2a 33 aa b3'; k['>']='2a 34 aa b4';
          k['$']='2a 05 aa 85';
          k['+']='2a 0d aa 8d';

          k['z'] = '2c ac'; k['x']  = '2d ad' ; k['c']  = '2e ae' ; k['v']  = '2f af'; k['b'] = '30 b0' ; k['n'] = '31 b1' ;
          k['m'] = '32 b2';
          k['Z'] = '2a 2c aa ac'; k['X']  = '2a 2d aa ad' ; k['C']  = '2a 2e aa ae' ; k['V']  = '2a 2f aa af';
           k['B'] = '2a 30 aa b0' ; k['N'] = '2a 31 aa b1' ; k['M'] = '2a 32 aa b2';
          
          k[',']= '33 b3' ; k['.']='34 b4'; k['/'] = '35 b5' ;k[':'] = '2a 27 aa a7';
          k['%'] = '2a 06 aa 86';  k['_'] = '2a 0c aa 8c';
          k['&'] = '2a 08 aa 88';
          k['('] = '2a 0a aa 8a';
          k[')'] = '2a 0b aa 8b';
          

        special=Hash.new;
        special['<Enter>'] = '1c 9c';
        special['<Backspace>'] = '0e 8e';
        special['<Spacebar>'] = '39 b9';
        special['<Return>'] = '1c 9c'
        special['<Esc>'] = '01 81';
        special['<Tab>'] = '0f 8f';
        special['<KillX>'] = '1d 38 0e';
        special['<Wait>'] = 'wait';

        special['<Up>'] = '48 c8';
        special['<Down>'] = '50 d0';
        #special['<PageUp>'] = '01';
        #special['<PageDown>'] = '01';

        keycodes=''
        thestring.gsub!(/ /,"<Spacebar>")

        until thestring.length == 0
          nospecial=true;
          special.keys.each { |key|
            if thestring =~ /^#{key}.*/i
              #take thestring
              #check if it starts with a special key + pop special string
              keycodes=keycodes+special[key]+' ';
               thestring=thestring.slice(key.length,thestring.length-key.length)
                nospecial=false;
              break;
            end
          }
          if nospecial
            code=k[thestring.slice(0,1)]
            if !code.nil?
              keycodes=keycodes+code+' '
            else
              puts "no scan code for #{thestring.slice(0,1)}"
            end
            #pop one
            thestring=thestring.slice(1,thestring.length-1)
          end
        end

          return keycodes
  end

end
