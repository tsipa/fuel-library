Facter.add("bootstrap_wsrep_cluster") do
  setcode do
    !File.exists? '/var/lib/mysql/grastate.dat'
  end
end

