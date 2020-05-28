output "ignition_file_id_list" {
   value = ["${compact(flatten(list(
     data.ignition_file.calico.*.id,
   )))}"]
 }
output "name" {
  value = "calico"
}
