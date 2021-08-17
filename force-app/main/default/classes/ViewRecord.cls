public with sharing class ViewRecord {
    private Id id;
    private String uniqueId;
    private String sObjectType;
    private String icon;
    private String title;
    private String status;
    private String userName;
    private Decimal points;
    private String otherString;
    private Datetime createdDate;
    private Datetime lastModifiedDate;
    private Boolean canEdit;
    
    public ViewRecord (Id id, String uniqueId, String sObjectType, String icon, String title, String status, String userName,
                       Decimal points, String otherString, Datetime createdDate, Datetime lastModifiedDate, Boolean canEdit) {
                           this.id = id;
                           this.uniqueId = uniqueId;
                           this.sObjectType = sObjectType;
                           this.icon = icon;
                           this.title = title;
                           this.status = status;
                           this.userName = userName;
                           this.points = points;
                           this.otherString = otherString;
                           this.createdDate = createdDate;
                           this.lastModifiedDate = lastModifiedDate;
                           this.canEdit = canEdit;
                       }
    
    @AuraEnabled
    public Id getId() {
        return id;
    }
    
    @AuraEnabled
    public String getUniqueId() {
        return uniqueId;
    }
    
    @AuraEnabled
    public String getSObjectType() {
        return sObjectType;
    }
    
    @AuraEnabled
    public String getIcon() {
        return icon;
    }
    
    @AuraEnabled
    public String getTitle() {
        return title;
    }
    
    @AuraEnabled
    public String getStatus() {
        return status;
    }
    
    @AuraEnabled
    public String getUserName() {
        return userName;
    }
    
    @AuraEnabled
    public Decimal getPoints() {
        return points;
    }
    
    @AuraEnabled
    public String getOtherString() {
        return otherString;
    }
    
    @AuraEnabled
    public Datetime getCreatedDate() {
        return createdDate;
    }
    
    @AuraEnabled
    public Datetime getLastModifiedDate() {
        return lastModifiedDate;
    }
    
    @AuraEnabled
    public Boolean getCanEdit() {
        return canEdit;
    }
}