/**
 * @description Class for handling the trigger on ContentVersion, used to share files to related records.
 */
public without sharing class HOT_LOS_ContentVersionHandler extends MyTriggers {
    /**
     * @description onAfterInsert trigger action
     */
    public override void onAfterInsert() {
        List<ContentVersion> salaryFileLOS = new List<ContentVersion>();
        for (ContentVersion cv : ((List<ContentVersion>) records)) {
            if (cv.FileType == 'CSV' && cv.Title.contains('LesehjelpLønnskravEksport')) {
                salaryFileLOS.add(cv);
            }
        }
        if (salaryFileLOS.size() > 0) {
            HOT_LOS_NotifyOnNewFile.HOT_LOS_NotifyOnNewFile(salaryFileLOS);
        }
    }
}
