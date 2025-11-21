public without sharing class HOT_LOS_ContentVersionHandler extends MyTriggers {
    public override void onAfterInsert() {
        List<ContentVersion> salaryFileLOS = new List<ContentVersion>();
        for (ContentVersion cv : ((List<ContentVersion>) records)) {
            if (cv.FileType == 'csv' && cv.Title.contains('LesehjelpLønnskravEksport')) {
                salaryFileLOS.add(cv);
            }
        }
        if (salaryFileLOS.size() > 0) {
            HOT_LOS_NotifyOnNewFile.notifyOnNewFile(salaryFileLOS);
        }
    }
}
