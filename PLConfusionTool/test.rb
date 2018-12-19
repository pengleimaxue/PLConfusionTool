
require 'xcodeproj'
#移除原有文件
def removeBuildPhaseFilesRecursively(aTarget, aGroup)
  aGroup.files.each do |file|
      if file.real_path.to_s.end_with?(".m", ".mm") then
          aTarget.source_build_phase.remove_file_reference(file)
      elsif file.real_path.to_s.end_with?(".plist") then
          aTarget.resources_build_phase.remove_file_reference(file)
      end
  end
  
  aGroup.groups.each do |group|
      removeBuildPhaseFilesRecursively(aTarget, group)
  end
end



def addFilesToGroup(aTarget, aGroup)
	
  Dir.foreach(aGroup.real_path) do |entry|
      filePath = File.join(aGroup.real_path, entry)
       puts (filePath)
      # 过滤目录和.DS_Store文件
      if !File.directory?(filePath) && entry != ".DS_Store" then
          # 向group中增加文件引用
          fileReference = aGroup.new_reference(filePath)
         
          # 如果不是头文件则继续增加到Build Phase中，PB文件需要加编译标志
          if filePath.to_s.end_with?("pbobjc.m", "pbobjc.mm") then
              aTarget.add_file_references([fileReference], '-fno-objc-arc')
          elsif filePath.to_s.end_with?(".m", ".mm") then
              aTarget.source_build_phase.add_file_reference(fileReference, true)
          elsif filePath.to_s.end_with?(".plist") then
              aTarget.resources_build_phase.add_file_reference(fileReference, true)
          end
      end
  end
end

#获取工程路径
project_path = File.join(File.dirname(__FILE__), "PLConfusionTool.xcodeproj")
project = Xcodeproj::Project.open(project_path)
puts project_path
#获得的就是以项目名命名的 Target, 一般都是 targets 数组中的第一个
target = project.targets.first 
#从它自身这个节点根据提供的path依次向下寻找，最后一个参数为如果没有找到，创建这个group
mapiGroup = project.main_group.find_subpath(File.join('confusionFile'), true)
mapiGroup.set_source_tree('<group>')
mapiGroup.set_path('./confusionFile')
#file_path = File.join(File.dirname(__FILE__), "PLConfusionTool")
#file_ref = mapiGroup.new_reference(file_path) 
#target.add_file_references([file_ref]) 
puts(mapiGroup.real_path)
puts(mapiGroup.empty?)
if mapiGroup.empty? then
  puts (mapiGroup.real_path)
	removeBuildPhaseFilesRecursively(target,mapiGroup)
	mapiGroup.clear()

	addFilesToGroup(target,mapiGroup)


end


project.save




