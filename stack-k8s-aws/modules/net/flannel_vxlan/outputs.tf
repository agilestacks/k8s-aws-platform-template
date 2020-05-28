output "ignition_file_id_list" {
   value = ["${compact(flatten(list(
     data.ignition_file.flannel.*.id,
   )))}"]
 }
output "name" {
  value = "flannel_vxlan"
}
