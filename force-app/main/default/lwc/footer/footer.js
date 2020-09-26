import { LightningElement } from 'lwc';
import footerLegal from '@salesforce/label/c.Footer_Legal';
import footerPrivacy from '@salesforce/label/c.Footer_Privacy';
import footerTerms from '@salesforce/label/c.Footer_Terms';
import footerTdAck from '@salesforce/label/c.Footer_TdAck';
import footerMyKeySight from '@salesforce/label/c.Footer_MyKeysight';
import footerMyProd from '@salesforce/label/c.Footer_MyProducts';
import footerMyWatch from '@salesforce/label/c.Footer_MyWatchList';
import footerMyDown from '@salesforce/label/c.Footer_MyDownLoad';
import footerMyNews from '@salesforce/label/c.Footer_MyNews';
import footerBuy from '@salesforce/label/c.Footer_Buy';
import footerHBR from '@salesforce/label/c.Footer_HBR';
import footerReqQuote from '@salesforce/label/c.Footer_ReqQuote';
import footerFindPartner from '@salesforce/label/c.Footer_FindPartner';
import footerSpcOffer from '@salesforce/label/c.Footer_SpcOffer';
import footerCheckOS from '@salesforce/label/c.Footer_CheckOrderStatus';
import footerVTO from '@salesforce/label/c.Footer_ViewTradeOffer';
import footerBProducts from '@salesforce/label/c.Footer_BrowserUsedEquip';
import footerWhyBKeySight from '@salesforce/label/c.Footer_WhyBuyKeySight';
import footerSupportTask from '@salesforce/label/c.Footer_SupportTask';
import footerManageLic from '@salesforce/label/c.Footer_ManageSoftLic';
import footerFindManual from '@salesforce/label/c.Footer_FindManual';
import footerUpdateSoftware from '@salesforce/label/c.Footer_UpdateSoftware';
import footerbrowseNotes from '@salesforce/label/c.Footer_BrowseAppNotes';
import footerRequestRepair from '@salesforce/label/c.Footer_RequestRepair';
import footerCheckWarning from '@salesforce/label/c.Footer_CheckWarrantyStatus';
import footerAskCommunity from '@salesforce/label/c.Footer_AskCommunity';
import footerFindPart from '@salesforce/label/c.Footer_FindPart';
import footerFeedback from '@salesforce/label/c.Footer_Feedback';
import footerContact from '@salesforce/label/c.Footer_Contact';

export default class Footer extends LightningElement {

    legalLabel = {
        footerLegal,
        footerPrivacy,
        footerTerms,
        footerTdAck
    };
    myKeySightLabel = {
        footerMyKeySight,
        footerMyProd,
        footerMyWatch,
        footerMyDown,
        footerMyNews
    };
    buyLabel = {
        footerBuy,
        footerHBR,
        footerReqQuote,
        footerFindPartner,
        footerSpcOffer,
        footerCheckOS,
        footerVTO,
        footerBProducts,
        footerWhyBKeySight

    };
    supportTaskLabel = {
        footerSupportTask,
        footerManageLic,
        footerFindManual,
        footerUpdateSoftware,
        footerbrowseNotes,
        footerRequestRepair,
        footerCheckWarning,
        footerAskCommunity,
        footerFindPart

    };
     copyRightLabel={ 
        footerFeedback,
        footerContact
     };
}