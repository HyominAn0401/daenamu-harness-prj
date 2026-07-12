{{- define "daenamu.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "daenamu.image" -}}
{{- $root := index . 0 -}}
{{- $svc := index . 1 -}}
{{- printf "%s/%s/%s:%s" $root.Values.global.imageRegistry $root.Values.global.imageProject $svc.image.repository $svc.image.tag -}}
{{- end -}}
