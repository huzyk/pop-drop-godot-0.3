@tool
extends SceneTree
## Configure CI export settings only. No secrets are stored in the project.
func _initialize() -> void:
	var android_sdk: String = OS.get_environment("ANDROID_HOME")
	var java_sdk: String = OS.get_environment("JAVA_HOME")
	if android_sdk.is_empty() or java_sdk.is_empty():
		push_error("ANDROID_HOME and JAVA_HOME are required for Android export")
		quit(1)
		return
	var settings: EditorSettings = EditorInterface.get_editor_settings()
	settings.set_setting("export/android/android_sdk_path",android_sdk)
	settings.set_setting("export/android/java_sdk_path",java_sdk)
	settings.save()
	print("PASS: configured Android SDK and OpenJDK 17 for CI export")
	quit()
