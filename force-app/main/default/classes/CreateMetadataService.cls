global with sharing class CreateMetadataService {

    public static MetadataService.MetadataPort createService() {
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;
    }

    public static List<MetadataService.SaveResult> createMetadata(MetadataService.Metadata input) {
        return createService().createMetadata(new List<MetadataService.Metadata> { input });
    }

    public static List<MetadataService.SaveResult> updateMetadata(MetadataService.Metadata input) {
        return createService().updateMetadata(new List<MetadataService.Metadata> { input });
    }

    public static List<MetadataService.DeleteResult> deleteMetadata(String type, String fullName) {
        return createService().deleteMetadata(type, new List<String> { fullName });
    }

}